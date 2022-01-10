
// #define TEST_MULTIGRID_MASK
#define EBERLY
#define MULTIGRID 1

#include "QSF.h"
#include "../getOpts.h"
#include <filesystem>

constexpr auto opt = OPTIMS::NONE;
constexpr auto order = 1;
using VTV = Split3Base<REP::X, REP::P, REP::X>;
using SplitType = MultiProductSplit<VTV, order>;
// using TVT = Split3Base<REP::P, REP::X, REP::P>;
// using SplitType = MultiProductSplit<TVT, order>;

int main(const int argc, char* argv[])
{
	using namespace QSF;
	cxxopts::Options options("argon-2e", "2e simulations of nitrogen");
	getOptDefs(options);
	auto result = options.parse(argc, argv);

	const bool remote = result["remote"].as<bool>();
	const bool continu = result["continue"].as<bool>();
	const bool testing = result["gaussian"].as<bool>();
	const double testing_momentum = result["momentum"].as<double>();
	logWarning("testing %d momentum %g", testing, testing_momentum);
	const ind nodes = result["nodes"].as<ind>();
	constexpr DIMS my_dim = 2_D;
	const ind nCAP = 32;//nodes / result["border"].as<ind>();
	const double omega = lambda_to_omega(result["lambda"].as<double>()); //0.0146978556546; //3100nm
	const double FWHM_cycles = result["fwhm"].as<double>();
	const double delay_in_cycles = result["delay"].as<double>();
	const double postdelay_in_cycles = result["postdelay"].as<double>();
	//The value 3.3 is empirical giving a nice smooth gaussian tail tending towards zero 
	const double ncycles = (testing ? 0.1 : round(FWHM_cycles * 3.3));
	const double phase_in_pi_units = result["phase"].as<double>();
	const double field = testing ? 0.0 : result["field"].as<double>();
	const double dx = result["dx"].as<double>();
	const double gsrcut = result["post-core-cut"].as<double>();
	const double re_dt = dx * 0.25;//dx * dx * 0.5;//result["dt"].as<double>();
	const int log_interval = testing ? 20 : 1000;
	// backup interval should be a multiple of log_interval
	const ind ncycle_steps = log_interval * (testing ? 1 : ind(round(10 * twopi / omega / re_dt) / log_interval));

	IO::path output_dir{ remote ? std::getenv("SCRATCH") : IO::project_dir };
	output_dir /= remote ? IO::project_name : IO::results_dir;
#ifdef EBERLY
	output_dir /= "eb";
#else
	output_dir /= "es";
#endif
	if (testing) output_dir /= "test";

	QSF::init(argc, argv, output_dir);

	if (result.count("help"))
	{
		if (!MPI::pID)
			std::cout << options.help({ "", "Laser", "Testing" }) << std::endl;
		QSF::finalize();
		exit(0);
	}

	InteractionBase config{ .Ncharge = 2.0, .Echarge = -1.0 };
#ifdef EBERLY
	config.Nsoft = config.Esoft = (testing ? 1000000.0 : 2.163);
	ReducedDimInteraction <ReducedModel::Eberly>potential{ config };
#else
	config.Nsoft = config.Esoft = (testing ? 1000000.0 : 2.2);
	ReducedDimInteraction <ReducedModel::EckhardSacha>potential{ config };
#endif
	if constexpr MODE_FILTER_OPT(MODE::IM)
	{
		QSF::subdirectory("groundstates");
		CAP<CartesianGrid<my_dim>> im_grid{ {dx, nodes}, nCAP };
		auto im_wf = Schrodinger::Spin0{ im_grid, potential };
		auto im_outputs = BufferedBinaryOutputs<
			VALUE<Step, Time>
			, OPERATION<Normalize>
			, AVG<Identity>
			, AVG<PotentialEnergy>
			, AVG<KineticEnergy>
			, ENERGY_TOTAL
			, ENERGY_DIFFERENCE
		>{ {.comp_interval = 1, .log_interval = log_interval} };

		auto p1 = SplitPropagator<MODE::IM, SplitType, decltype(im_wf)>
		{
			{.dt = re_dt, .max_steps = 1000000, .state_accuracy = 10E-15},
			std::move(im_wf)
		};

		p1.run(im_outputs,
			   [&](const WHEN when, const ind step, const uind pass, auto& wf)
			   {
				   if (when == WHEN::AT_START)
				   {
					   wf.addUsingCoordinateFunction(
						   [](auto... x) -> cxd
						   {
							   return cxd{ gaussian(0.0, 5.0, x...), 0 };
						   });
					   logUser("wf loaded manually!");
				   }
				   if (when == WHEN::AT_END)
					   wf.save(std::to_string(nodes) + "_" + std::to_string(dx));
			   });
	}

	// ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	// Real-time part :::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if constexpr MODE_FILTER_OPT(MODE::RE)
	{
		if (testing)
			QSF::subdirectory("testing");
		else
			QSF::subdirectory(
				IO::path("flux_quiver_ratio_" + std::to_string(result["flux-quiver-ratio"].as<double>())) /
				IO::path("nm_" + std::to_string((int)result["lambda"].as<double>())) /
				IO::path("fwhm_cycles_" + std::to_string(FWHM_cycles)) / IO::path("phase_" + std::to_string(phase_in_pi_units)));
		   // We need to pass absolute path 
		IO::path im_output = IO::root_dir / IO::path("groundstates/" + std::to_string(nodes) + "_" + std::to_string(dx) + "_repX");

	#ifdef MULTIGRID
		CAP<MultiCartesianGrid<my_dim>> re_capped_grid{ {dx, nodes}, nodes / 4 };
	#else
		CAP<CartesianGrid<my_dim>> re_capped_grid{ {dx, nodes}, nCAP };
	#endif
		using A1 = VectorPotential<AXIS::XY, GaussianEnvelope<SinPulse>, ConstantPulse>;
		DipoleCoupling<VelocityGauge, A1> re_coupling
		{
			A1{
			GaussianEnvelope<SinPulse>{ {
				.field = field * sqrt(3.) * 0.5 / omega,
				.omega = omega,
				.ncycles = ncycles,
				.FWHM_percent = FWHM_cycles / ncycles,
				.phase_in_pi_units = phase_in_pi_units,
				.delay_in_cycles = delay_in_cycles}},
			ConstantPulse { {
				.field = field,
				.omega = omega,
				.ncycles = postdelay_in_cycles,
				.delay_in_cycles = ncycles}}
			}
		};

		double quiver = field / omega / omega;
		//TODO: UNCOMMENT
		// if (quiver > nodes / 4 / dx)
			// logError("Effective grid size (%g) should fit at least a single quiver length (%g)", nodes / 4 / dx, quiver);
			// p_NS: position of borders between N and S regions (standard: 12.5)
		p_NS = (ind)(quiver * result["flux-quiver-ratio"].as<double>() / dx);
		// p_SD: position of borders between S and D regions (standard: 7)
		p_SD = (ind)p_NS / 2;
		p_CAP = nodes / 4;
		logInfo("quiver [%g] %ld %ld %ld\n", quiver, p_NS, p_SD, p_CAP);
		auto re_outputs = BufferedBinaryOutputs <
			VALUE<Step, Time>
			, VALUE<A1>
			, AVG<Identity>
			// , AVG<PotentialEnergy>
			// , AVG<KineticEnergy>
			// , AVG<DERIVATIVE<0, PotentialEnergy>>
			, ZOA_FLUX_2D
			, VALUE<ETA>
		>{ {.comp_interval = 1, .log_interval = log_interval} };

		auto re_wf = Schrodinger::Spin0{ re_capped_grid, potential, re_coupling };
		auto p2 = SplitPropagator<MODE::RE, SplitType, decltype(re_wf)>{ {.dt = re_dt}, std::move(re_wf) };

		p2.run(re_outputs,
			   [=](const WHEN when, const ind step, const uind pass, auto& wf)
			   {
				   if (testing)
				   {
					   if ((when == WHEN::AT_START) && (MPI::region == 0))
					   {
						   wf.addUsingCoordinateFunction(
							   [=](auto... x) -> cxd
							   {
								   double mom = ((x * testing_momentum) + ...);
								   return gaussian(0.0, 4.0, x...) * cxd { cos(mom), sin(mom) };
							   });
					   }
					   if (when == WHEN::DURING)
					   {
						   if (step == 1 || step % ncycle_steps == ncycle_steps - 1)
						   {
							   wf.snapshot("_step" + std::to_string(step), DUMP_FORMAT{ .dim = my_dim, .rep = REP::X });
							   wf.snapshot("_step" + std::to_string(step), DUMP_FORMAT{ .dim = my_dim, .rep = REP::P });
							   wf.backup(step);
						   }

					   }
					   if (when == WHEN::AT_END)
					   {
						   wf.snapshot("_step" + std::to_string(step), DUMP_FORMAT{ .dim = my_dim, .rep = REP::X });
						   wf.snapshot("_step" + std::to_string(step), DUMP_FORMAT{ .dim = my_dim, .rep = REP::P });
						   if (MPI::region == 3) wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P });
						   wf.save("sep_final", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P });
						   wf.saveIonizedJoined("final", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P });

					   }

				   }
				   else
				   {
					   if ((when == WHEN::AT_START) && (MPI::region == 0)) wf.load(im_output);
					   else if (when == WHEN::DURING && (step % ncycle_steps == 0))
					   {
						   wf.backup(step);
					   }
					   else if (when == WHEN::AT_END)
					   {
					   #ifdef MULTIGRID
						//    if (MPI::region == 3) 
						   wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::X, .downscale = 1 });
						   wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 1 });
						   wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::X, .downscale = 8 });
						   wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 8 });
						//    wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 2 });
						//    wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 4 });
						//    wf.save("momenta", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 8 });
						   wf.saveIonizedJoined("final", DUMP_FORMAT{ .dim = my_dim, .rep = REP::P });
					   #else
						   auto name = "n" + std::to_string(nodes) + "_dx" + std::to_string(dx) + "_dt" + std::to_string(re_dt)
							   + "_p" + std::to_string(postdelay_in_cycles) + "_g" + std::to_string(gsrcut);

						   wf.croossOut(gsrcut);
						   wf.save(name, DUMP_FORMAT{ .dim = my_dim, .rep = REP::P });
						   wf.save(name, DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 2 });
						   wf.save(name, DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 4 });
						   wf.save(name, DUMP_FORMAT{ .dim = my_dim, .rep = REP::P, .downscale = 8 });
					   #endif
					   }
				   }

					   }, continu);
				   }


	QSF::finalize();
		}


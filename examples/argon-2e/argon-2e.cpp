
// #define TEST_MULTIGRID_MASK
#include "../getOpts.h"
#include "QSF.h"

#ifndef MODEL
/// @brief This defines the default compile-time model to use
/// @note Custom model could be passed directly to a compiler
#define MODEL ReducedModel::EckhardSacha
#endif
#ifndef GRIDTYPE
/// @brief This defines the default compile-time grid time to use
/// @note Custom grid type could be passed directly to a compiler
#define GRIDTYPE MultiCartesianGrid<my_dim>
#endif

/// @brief Dimensionality of the project
constexpr DIMS my_dim		 = 2_D;
/// @brief Order of operator splitting
constexpr auto splitOrder= 1;
/// @brief Number of grid points to be used by Complex Absrobing Potential margin during imaginary
/// propagation
constexpr ind nCAP			 = 32;
/// @brief Shorthand for describing type of base operator splitting
using VTV								 = Split3Base<REP::X, REP::P, REP::X>;
/// @brief Shorthand for describing type of operator splitting of fixed order
using SplitType					 = MultiProductSplit<VTV, splitOrder>;

/// @brief Initializes program options
cxxopts::Options options("argon-2e", "2e simulations of nitrogen");

int main(const int argc, char* argv[])
{
	using namespace QSF;

#pragma region Config

	getOptDefs(options);
	ropts														= options.parse(argc, argv);
	/// @brief Number of grid nodes in one dimension
	const ind nodes									= opt<ind>("nodes");
	/// @brief Spacing between grid nodes
	const double dx									= opt<double>("dx");
	/// @brief Time delta used in real-time evolution
	const double re_dt							= dx * 0.25;	 // dx * dx * 0.5;//ropts["dt"].as<double>();
	/// @brief Mangnitu
	const double field							= opt<double>("field");
	/// @brief Number of cycles at Full Width Half Maximum
	const double FWHM_cycles				= opt<double>("fwhm");
	/// @brief Total number of cycles. The multiplier 3.3 is empirical.
	/// It gives nice smooth gaussian tail tending towards zero
	const double ncycles						= round(FWHM_cycles * 3.3);
	/// @brief Delay before the radiation is turned on
	const double delay_in_cycles		= opt<double>("delay");
	/// @brief Phase of the radiation
	const double phase_in_pi_units	= opt<double>("phase");
	/// @brief Delay after the radiation ends and the simulation end
	const double postdelay_in_cycles= opt<double>("postdelay");
	/// @brief Frequency of the radiation
	const double omega							= lambda_to_omega(opt<double>("lambda"));
	/// @brief
	const double gsrcut							= opt<double>("post-core-cut");
	/// @brief how often the program will log to the console
	const int log_interval					= 1000;
	/// @brief Backup interval
	/// @note should be a multiple of log_interval
	const ind ncycle_steps= log_interval * ind(round(2 * twopi / omega / re_dt) / log_interval);

	/// @brief Here we set the output directory
	/// If a parameter option "remote" is true we'll use a custom place to store the data
	/// This is useful for computational clusters like Prometheus which have designated
	/// partitions (e.g. SCRATCH) for storage of temporary, large files
	IO::path output_dir{opt<bool>("remote") ? std::getenv("SCRATCH") : IO::project_dir};
	output_dir/= opt<bool>("remote") ? IO::project_name : IO::results_dir;
	output_dir/= (MODEL == ReducedModel::Eberly ? "model_eb" : "model_es");
	QSF::init(argc, argv, output_dir);

	/// @brief Defines how to display help for options
	if(ropts.count("help"))
	{
		if(!MPI::pID) std::cout << options.help({"", "Environment", "Laser"}) << std::endl;
		QSF::finalize();
		exit(0);
	}

	// Setting up the interaction
	InteractionBase config{.Ncharge= 2.0, .Echarge= e};
	config.Nsoft= config.Esoft= (MODEL == ReducedModel::Eberly ? 2.163 : 2.2);
	ReducedDimInteraction<MODEL> potential{config};

#pragma endregion

	// Imag-time part ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if constexpr
		MODE_FILTER_OPT(MODE::IM)
		{
			QSF::subdirectory("groundstates");

			CAP<CartesianGrid<my_dim>> im_grid{{dx, nodes}, nCAP};
			auto im_wf		 = Schrodinger::Spin0{im_grid, potential};
			///  BufferedBinaryOutputs<...> is an alias of BufferedOutputs<true,...>
			auto im_outputs= BufferedBinaryOutputs<
				VALUE<Step, Time>,
				OPERATION<Normalize>,
				AVG<Identity>,
				AVG<PotentialEnergy>,
				AVG<KineticEnergy>,
				ENERGY_TOTAL,
				ENERGY_DIFFERENCE>{{.comp_interval= 1, .log_interval= log_interval}};

			auto p1= SplitPropagator<MODE::IM, SplitType, decltype(im_wf)>{
				{.dt= re_dt, .max_steps= 1000000, .state_accuracy= 10E-15}, std::move(im_wf)};

			p1.run(
				im_outputs,
				[&](const WHEN when, const ind step, const uind pass, decltype(im_wf)& wf)
				{
					if(when == WHEN::AT_START)
					{
						wf.addUsingCoordinateFunction(
							[](auto... x) -> cxd {
								return cxd{gaussian(0.0, 5.0, x...), 0};
							});
						logUser("Populated with initial gaussian");
					}
					if(when == WHEN::AT_END) wf.save(std::to_string(nodes) + "_" + std::to_string(dx));
				});
		}

	// Real-time part ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	if constexpr
		MODE_FILTER_OPT(MODE::RE)
		{
			QSF::subdirectory(
				IO::path("flux_quiver_ratio_" + std::to_string(opt<double>("flux-quiver-ratio"))) /
				IO::path("nm_" + std::to_string((int)opt<double>("lambda"))) /
				IO::path("fwhm_cycles_" + std::to_string(FWHM_cycles)) /
				IO::path("phase_" + std::to_string(phase_in_pi_units)));
			// We need to pass absolute path to reach the input
			IO::path im_output=
				IO::root_dir /
				IO::path("groundstates/" + std::to_string(nodes) + "_" + std::to_string(dx) + "_repX");

			CAP<GRIDTYPE> re_capped_grid{{dx, nodes}, nodes / 4};
			using A1= VectorPotential<AXIS::XY, GaussianEnvelope<SinPulse>, ConstantPulse>;
			DipoleCoupling<VelocityGauge, A1> re_coupling{A1{
				GaussianEnvelope<SinPulse>{
					{.field						 = field * sqrt(3.) * 0.5 / omega,
					 .omega						 = omega,
					 .ncycles					 = ncycles,
					 .FWHM_percent		 = FWHM_cycles / ncycles,
					 .phase_in_pi_units= phase_in_pi_units,
					 .delay_in_cycles	 = delay_in_cycles}},
				ConstantPulse{
					{.field= 0, .omega= omega, .ncycles= postdelay_in_cycles, .delay_in_cycles= ncycles}}}};

			double quiver= field / omega / omega;

			if(quiver > nodes / 4 / dx)
				logError(
					"Effective grid size (%g) should fit at least a single quiver length (%g)",
					nodes / 4 / dx,
					quiver);
			// p_NS: position of borders between N and S regions (standard: 12.5)
			p_NS = (ind)(quiver * opt<double>("flux-quiver-ratio") / dx);
			// p_SD: position of borders between S and D regions (standard: 7)
			p_SD = (ind)p_NS / 2;
			p_CAP= nodes / 4;
			logInfo("quiver [%g] %ld %ld %ld\n", quiver, p_NS, p_SD, p_CAP);
			auto re_outputs= BufferedBinaryOutputs<
				VALUE<Step, Time>,
				VALUE<A1>
				// , AVG<Identity>
				// , AVG<PotentialEnergy>
				// , AVG<KineticEnergy>
				// , AVG<DERIVATIVE<0, PotentialEnergy>>
				// , ZOA_FLUX_2D
				,
				VALUE<ETA>>{{.comp_interval= 1, .log_interval= log_interval}};

			auto re_wf= Schrodinger::Spin0{re_capped_grid, potential, re_coupling};
			auto p2=
				SplitPropagator<MODE::RE, SplitType, decltype(re_wf)>{{.dt= re_dt}, std::move(re_wf)};

			p2.run(
				re_outputs,
				[=](const WHEN when, const ind step, const uind pass, auto& wf)
				{
					if((when == WHEN::AT_START) && (MPI::region == 0)) wf.load(im_output);
					else if(when == WHEN::DURING && (step % ncycle_steps == 0))
					{
						//    wf.backup(step);
						//    wf.snapshot("", DUMP_FORMAT{ .dim = my_dim, .rep = REP::X, .downscale = 1 });
						wf.snapshot("", DUMP_FORMAT{.dim= my_dim, .rep= REP::P, .downscale= 1});
					}
					else if(when == WHEN::AT_END)
					{
						if constexpr(!std::is_same_v<MultiCartesianGrid<my_dim>, GRIDTYPE>)
							wf.croossOut(gsrcut);

						wf.save("momenta", DUMP_FORMAT{.dim= my_dim, .rep= REP::X, .downscale= 1});
						wf.save("momenta", DUMP_FORMAT{.dim= my_dim, .rep= REP::P, .downscale= 1});
						wf.save("momenta", DUMP_FORMAT{.dim= my_dim, .rep= REP::X, .downscale= 8});
						wf.save("momenta", DUMP_FORMAT{.dim= my_dim, .rep= REP::P, .downscale= 8});
						if constexpr(std::is_same_v<MultiCartesianGrid<my_dim>, GRIDTYPE>)
							wf.saveIonizedJoined("momenta_joined", DUMP_FORMAT{.dim= my_dim, .rep= REP::P});
					}
				},
				opt<bool>("continue"));
		}

	QSF::finalize();
}

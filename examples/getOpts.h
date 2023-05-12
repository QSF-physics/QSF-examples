#pragma once

#include "basics/data_types.h"
#include "cxxopts.hpp"
cxxopts::ParseResult ropts;

/// @brief Shorthand for reading program options
/// @tparam T type name of the option
/// @param o options name
template<class T> T opt(std::string&& o) { return ropts[o].as<T>(); }

/// @brief Adds often used default options to program options
/// @param options reference
void getOptDefs(cxxopts::Options& options)
{
	using namespace cxxopts;
	options.add_options()("h,help", "Print help")(
		"n,nodes", "Number of nodes [positive integer]", value<ind>()->default_value("1024"))(
		"x,dx", "Set the spacedelta [a.u.]", value<double>()->default_value("0.2"))(
		"post-core-cut",
		"Set the range from core to cut after propagation [a.u.]",
		value<double>()->default_value("50.0"))(
		"flux-quiver-ratio",
		"Set the place at which flux surfaces stay in relative to quiver length [%]",
		value<double>()->default_value("2.0"));
	// ("t,dt", "Set the timedelta [a.u.]",
	//  value<double>()->default_value("0.2"))
	// ("s,soft", "Set the coulomb softener (epsilon) [length^2]=[a.u.^2]",
	//  value<double>()->default_value("0.92"))
	// ("b,border", "Number of border nodes defined as nCAP=nodes/# [positive integer]",
	//  value<ind>()->default_value("4"));

	options.add_options("Environment")(
		"r,remote", "Running on remote cluster (AGH Prometeusz) (default: false)")(
		"k,continue", "Continue calculations from the latest backup (default: false)");

	options.add_options("Testing")("g,gaussian", "Start from gaussian wavepacket (default: false)")(
		"m,momentum", "Initial momentum of gaussian wavepacket", value<double>()->default_value("3.0"));

	options.add_options("Laser")(
		"f,field",
		"Field strength [a.u] value (default: 8*10^13 W/cm2)",
		value<double>()->default_value("0.0477447629"))(
		"l,lambda", "Wavelength [nm] value (default: 3100nm)", value<double>()->default_value("3100"))(
		"p,phase", "Carrier Envelope Phase (CEP) [pi] value", value<double>()->default_value("0.0"))(
		"d,delay", "pulse delay [cycles]", value<double>()->default_value("0.0"))(
		"o,postdelay", "post-pulse delay [cycles]", value<double>()->default_value("1.0"))(
		"w,fwhm", "FWHM [cycles]", value<double>()->default_value("6.0"));
}
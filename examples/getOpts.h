#pragma once

#include "cxxopts.hpp"

cxxopts::ParseResult ropts;
template <class T> T opt(std::string&& o) { return ropts[o].as<T>(); }

void getOptDefs(cxxopts::Options& options)
{
	options.add_options()
		("h,help", "Print help")
		("n,nodes", "Number of nodes [positive integer]",
		 cxxopts::value<ind>()->default_value("1024"))
		("x,dx", "Set the spacedelta [a.u.]",
		 cxxopts::value<double>()->default_value("0.2"))
		("post-core-cut", "Set the range from core to cut after propagation [a.u.]",
		 cxxopts::value<double>()->default_value("50.0"))
		("flux-quiver-ratio", "Set the place at which flux surfaces stay in relative to quiver length [%]",
		 cxxopts::value<double>()->default_value("2.0"));
	// ("t,dt", "Set the timedelta [a.u.]",
	//  cxxopts::value<double>()->default_value("0.2"))
	// ("s,soft", "Set the coulomb softener (epsilon) [length^2]=[a.u.^2]",
	//  cxxopts::value<double>()->default_value("0.92"))
	// ("b,border", "Number of border nodes defined as nCAP=nodes/# [positive integer]",
	//  cxxopts::value<ind>()->default_value("4"));

	options.add_options("Environment")
		("r,remote", "Running on remote cluster (AGH Prometeusz) (default: false)")
		("k,continue", "Continue calculations from the latest backup (default: false)");

	options.add_options("Testing")
		("g,gaussian", "Start from gaussian wavepacket (default: false)")
		("m,momentum", "Initial momentum of gaussian wavepacket",
		 cxxopts::value<double>()->default_value("3.0"));

	options.add_options("Laser")
		("f,field", "Field strength [a.u] value (default: 8*10^13 W/cm2)",
		 cxxopts::value<double>()->default_value("0.0477447629"))
		("l,lambda", "Wavelength [nm] value (default: 3100nm)",
		 cxxopts::value<double>()->default_value("3100"))
		("p,phase", "Carrier Envelope Phase (CEP) [pi] value",
		 cxxopts::value<double>()->default_value("0.0"))
		("d,delay", "pulse delay [cycles]",
		 cxxopts::value<double>()->default_value("0.0"))
		("o,postdelay", "post-pulse delay [cycles]",
		 cxxopts::value<double>()->default_value("1.0"))
		("w,fwhm", "FWHM [cycles]",
		 cxxopts::value<double>()->default_value("6.0"));
}
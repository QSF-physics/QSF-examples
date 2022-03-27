#!/usr/bin/env wolframscript

(* << "ForScience`";
<< "ForScience`Util`";
<< "ForScience`PlotUtils`"; *)
<<"PlotGrid`";
<<"cmdline`opt`";
<<"filestruct`";
Needs["QSF`"];
Needs["QSF`wf`"];
Needs["QSF`styling`"];

(* Number of stars correspond to the hierarchy (dictionary) level created by ParsePattern*)
(* ParseFilter can be any kind of string validation, Identity passes through everything,
WFFileNameQ and DataFileNameQ are predefined in the QSF`wf and QSF`data packages*)
fileStruct=ParsePattern[
"Results/model_*/flux_quiver_ratio_2.000000/nm_**/fwhm_cycles_***/phase_0.5****/momenta_repP.psi3*****", "ParseFilter"->Identity];

DP:=Print[ToString[#,InputForm]]&;
rng=4;
processed=StructProcess[fileStruct, 
"Operations"->
{
    "/Users/ranza/Projects/Quantum/NSDI-paper/"
    ,"FileFormat"->"pdf"
    (* ,"LeafPath"->"path/filename"  *)
    ,"TrimMarginsPercent"->0.2
    ,"WFMaskEdgeAtRatio"->0.7
    ,4 ->TrimMargins@*Average@*RemoveBoundedPart@*WFLoad
    ,StructPeak
    ,PrettyPlots
    ,{
        (* "wf2d/full/"
        ,PlotRange->{{-rng,rng},{-rng,rng},Full}
        (* FrameTicks->{{True, True},{None, True}}, *)
        ,1->WFExport@*WFPlot *)
    }
    (* ,1->MergeOrthants *)
    ,{
        (* {
            "wf2d/orthants_merged"
            ,PlotRange->{{0,rng},{0,rng},Full}
            ,1->WFExport@*WFPlot
        }
        ,{
            "wf2d/orthants_merged_and_blured"
            ,"GaussianBlurRadius"->0.05
            ,PlotRange->{{0,rng},{0,rng},Full}
            ,1->WFExport@*WFPlot@*GaussianBlur
        } *)
        {
            "wf1d/orthants_merged_and_blured_transverse_diag"
            ,LegendLabel -> "label"
            ,PlotRange->{{0,rng*Sqrt[2]/2},Full}
            ,2->WFCombine@*TransverseDiagSum
            ,"GridTranspose"->True
            ,0 ->WFGrid
            (* ,DP *)
            ,0->WFExport
            (* ,2->Print@*WFPlot@*TransverseDiagSum *)
            (* ,StructPeak *)
            (* ,DP *)
            (* ,0->WFExport  *)
            (* @*WFGrid *)

            ,StructPeak
            (* ,3->WFCombine@*GaussianBlur@*TransverseDiagSum *)
            (* ,2->WFExport@*WFGrid *)
        }
    }
    
    (* ,{
        "LegendPlacement"->Top,
        GridLines->Full, 
        Axes->False, PlotRange->{{0,2},Full}, 
        "elo",
        PrettyPlots, 
        3->WFCombine@*GaussianBlur@*TransverseDiagSum@*MergeOrthants,
        
        StructPeak,
        1->WFExport,
        StructPeak
    } *)
        (* {GridLines->Full, Axes->False, PlotRange->Full, 0->WFPlot,StructPeak, WFExport} *)
}];

(* {2 ->((Print[Head[#]])&/@WFLoad[#]&),1->PrintHead}]; *)
(* WFMultiExport[processed]; *)
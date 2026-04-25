



/****************************************************************************************
Project: Rural Roads and Factor Misallocation in Agriculture
Purpose: Replicate main result tables
****************************************************************************************/



cd "C:\Users\wb643922\Downloads\ReplicationFiles"

global road_treat "ea_road_surface_treatment.dta"

*----------------------------------*
* Fixed effects
*----------------------------------*
global FE_ea_zone   "absorb(ea_id_obs zone_year)"

*----------------------------------*
* Main sample
*----------------------------------*
global mainsample "ever_improve==1 & wave<3"

*----------------------------------*
* Global function
*----------------------------------*
capture program drop add_table_rows
program define add_table_rows
    syntax, controls(string) fe1(string) fe2(string)

    estadd local controls_row "`controls'"
    estadd local fe1_row      "`fe1'"
    estadd local fe2_row      "`fe2'"
end




/****************************************************************************************
A. MAIN RESULTS
****************************************************************************************/

*========================================================================================*
* Table 2. Road Improvement and Household-Level Misallocation
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo T2_`y': reghdfe `y' treated_post if $mainsample, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

esttab T2_abslog_mpL_gap T2_abslog_mpN_gap T2_abslog_mpK_gap T2_effgain_hh ///
    using "Table 2.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(treated_post) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table 2. Road Improvement and Household-Level Misallocation") ///
    addnotes("Notes: Each column reports a separate household-level difference-in-differences regression. The treatment indicator equals one for households observed after road improvement in their enumeration area. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. Standard errors are clustered at the enumeration-area level. Columns 1-3 report absolute log deviations of household marginal products of land, labor, and capital from the enumeration-area mean. Column 4 reports the absolute log gap between output under the efficient allocation and output under the observed allocation.")


*========================================================================================*
* Table 3. Road Improvement and Between-Household Input-Productivity Mismatch
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in abslog_land_fe_gap abslog_labor_fe_gap abslog_capital_fe_gap {
    eststo T3_`y': reghdfe `y' treated_post if $mainsample, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

esttab T3_abslog_land_fe_gap T3_abslog_labor_fe_gap T3_abslog_capital_fe_gap ///
    using "Table 3.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land mismatch" "Labor mismatch" "Capital mismatch") ///
    keep(treated_post) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table 3. Road Improvement and Between-Household Input-Productivity Mismatch") ///
    addnotes("Notes: Each column reports a separate household-level difference-in-differences regression. The outcomes are absolute log deviations of household input allocation relative to permanent productivity from the village-round average, measured separately for land, labor, and capital. Lower values indicate that inputs are more closely aligned with household productivity across households within the enumeration area. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. Standard errors are clustered at the enumeration-area level.")


*========================================================================================*
* Table 4. Road Improvement and Within-Household Plot-Level Misallocation
*========================================================================================*

* Household-wave outcomes
use "misalloc_household.dta", clear
merge m:1 wave hh_id_merge using "misalloc_within_hh.dta", keep(1 3) nogen
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in Sd_mpA_hw Sd_mpL_hw {
    eststo T4_`y': reghdfe `y' treated_post if $mainsample, ///
        $FE_hh_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

* Plot-level outcomes
use "misalloc_household.dta", clear
merge 1:m wave hh_id_merge using "misalloc_plotlevel.dta", keep(1 3) nogen
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

foreach y in abslog_mpA_gap_plot abslog_mpL_gap_plot {
    eststo T4_`y': reghdfe `y' treated_post if $mainsample, ///
        $FE_hh_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

esttab T4_Sd_mpA_hw T4_Sd_mpL_hw T4_abslog_mpA_gap_plot T4_abslog_mpL_gap_plot ///
    using "Table 4.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Within-HH SD MP land" "Within-HH SD MP labor" "Plot MP land gap" "Plot MP labor gap") ///
    keep(treated_post) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "Household fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table 4. Road Improvement and Within-Household Plot-Level Misallocation") ///
    addnotes("Notes: Each column reports a separate difference-in-differences regression examining whether road improvement changes within-household misallocation across plots. Columns 1 and 2 use household-wave outcomes equal to the within-household standard deviation of log marginal products of land and labor across plots. Columns 3 and 4 use plot-level outcomes equal to the absolute log deviation of each plot's marginal product of land or labor from the household-wave mean. The sample is restricted to households operating at least two plots in enumeration areas that are eventually improved and to waves 1 and 2. All specifications include household fixed effects and zone-by-year fixed effects. Standard errors are clustered at the enumeration-area level.")


	

	
/****************************************************************************************
B. RONUSTNESS
****************************************************************************************/

	
*========================================================================================*
* Table 5. Road Improvement and Village-Level Misallocation
*========================================================================================*
use "misalloc_village.dta", clear
merge 1:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in Sd_mpL_vt Sd_mpN_vt Sd_mpK_vt Sd_land_fe Sd_labor_fe Sd_capital_fe {
    eststo T5_`y': reghdfe `y' treated_post if $mainsample, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

esttab T5_Sd_mpL_vt T5_Sd_mpN_vt T5_Sd_mpK_vt T5_Sd_land_fe T5_Sd_labor_fe T5_Sd_capital_fe ///
    using "Table 5.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP dispersion" "Labor MP dispersion" "Capital MP dispersion" "Land Mismatch" "Labor Mismatch" "Capital Mismatch") ///
    keep(treated_post) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table 5. Road Improvement and Village-Level Misallocation") ///
    addnotes("Notes: Each column reports a separate difference-in-differences regression at the enumeration-area level. Columns (1)-(3) report within-enumeration-area standard deviations of log marginal products for land, labor, and capital. Columns (4)-(6) report within-enumeration-area dispersions of log input allocation relative to permanent farm productivity for land, labor, and capital. Lower values indicate lower misallocation and a closer alignment between input allocation and household productivity within the enumeration area. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. Standard errors are clustered at the enumeration-area level.")


	
	
*========================================================================================*
* Table 6 and 7. Road Improvement and Household-Level Misallocation with Controls
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

global controls "evi_peak mean_temp_c precip_ann_mm"

eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo T7_`y': reghdfe `y' treated_post $controls if $mainsample, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("Yes") fe1("Yes") fe2("Yes")
}

esttab T7_abslog_mpL_gap T7_abslog_mpN_gap T7_abslog_mpK_gap T7_effgain_hh ///
    using "Table 6.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(treated_post) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table 7. Road Improvement and Household-Level Misallocation with Time-varying Controls") ///
    addnotes("Notes: Each column reports a separate household-level difference-in-differences regression with controls. Controls include peak vegetation index, mean temperature, and annual precipitation. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. Standard errors are clustered at the enumeration-area level.")

	

use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen
merge m:1 wave ea_id using "sum_productivity.dta", nogen

foreach v in dist_tar_km dist_popcenter dist_market dist_admctr dist_urban_km ///
                 lan_productivity lab_productivity {
				 	replace `v' = . if wave ~= 1
					bys ea_id_obs: egen  b`v' = mean(`v')
				 }

	
global controls1 "evi_peak mean_temp_c precip_ann_mm"
global controls2 "bdist_tar_km bdist_market blan_productivity"

gen post = wave == 2

eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo T7_`y': reghdfe `y' treated_post $controls1 ///
	i.post#c.($controls2) ///
	if $mainsample, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("Yes") fe1("Yes") fe2("Yes")
}


esttab T7_abslog_mpL_gap T7_abslog_mpN_gap T7_abslog_mpK_gap T7_effgain_hh ///
    using "Table 7.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(treated_post) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table 7. Road Improvement and Household-Level Misallocation with Baseline Controls") ///
    addnotes("Notes: Each column reports a separate household-level difference-in-differences regression with controls. Controls include baseline distance to asphalt road, distance to nearest market, and land productivity (measured in value of output per hacetare), all are intracted with post dummy. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. Standard errors are clustered at the enumeration-area level.")
	
	
		
	
	
/****************************************************************************************
C. HETEROGENEITY BY BASELINE CERTIFICATE SHARE
****************************************************************************************/


*========================================================================================*
* Table 8. Heterogeneity by Baseline Certificate Share: Household-Level Outcomes
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo T9_`y': reghdfe `y' treated_post post_cert_t0 road_cert_t0 if $mainsample, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

esttab T9_abslog_mpL_gap T9_abslog_mpN_gap T9_abslog_mpK_gap T9_effgain_hh ///
    using "Table 9.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(treated_post post_cert_t0 road_cert_t0) ///
    order(treated_post post_cert_t0 road_cert_t0) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table 9. Heterogeneity by Baseline Certificate Share: Household-Level Outcomes") ///
    addnotes("Notes: Each column reports a separate household-level regression with heterogeneity by baseline land certificate prevalence. Baseline certificate share is measured before treatment. The specification includes the treatment indicator and its interaction with baseline certificate share. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. Standard errors are clustered at the enumeration-area level.")


	
	
	
	
/****************************************************************************************
D. SUMMARY STATISTICS
****************************************************************************************/

*========================================================================================*
* Table 1A. Summary Statistics for Household-Level Variables
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen
keep if $mainsample

eststo clear
estpost summarize ///
    abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh ///
	abslog_land_fe_gap abslog_labor_fe_gap abslog_capital_fe_gap ///
    value_add total_labor_days plot_area_GPS capital_total_usd

esttab using "Table 1A.rtf", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    label nonumber nomtitles nonotes ///
    title("Table 1A. Summary Statistics for Household-Level Variables") ///
    addnotes("Notes: The table reports summary statistics for the household-level analysis sample. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. The first four variables are the household-level misallocation measures used in the main analysis. Value added is measured net of purchased intermediate inputs. Labor is measured in total labor days. Land is measured in cultivated hectares. Capital is measured in U.S. dollars.")


*========================================================================================*
* Table 1B. Summary Statistics for Enumeration-Area Variables
*========================================================================================*
use "misalloc_village.dta", clear
merge 1:1 wave ea_id using "$road_treat", keep(3) nogen
keep if $mainsample

eststo clear
estpost summarize ///
    Sd_mpL_vt Sd_mpN_vt Sd_mpK_vt  ///
	Sd_land_fe Sd_labor_fe Sd_capital_fe ///
    treated_post cert_share_t0

esttab using "Table 1B.rtf", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    label nonumber nomtitles nonotes ///
    title("Table 1B. Summary Statistics for Enumeration-Area Variables") ///
    addnotes("Notes: The table reports summary statistics for the enumeration-area analysis sample. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. The first three variables are within-area dispersions of log marginal products for land, labor, and capital. The efficiency-gap measure is the absolute log ratio of efficient to observed aggregate output. The final two variables indicate treatment status and baseline land certificate prevalence.")
	
	


/****************************************************************************************
E. APPENDIX TABLES
****************************************************************************************/

*========================================================================================*
* Table A1. Baseline Covariate Balance: Accessibility Measures
*========================================================================================*
use "$road_treat", clear
merge 1:1 wave ea_id using "sum_productivity.dta", nogen

keep if ever_improve==1

bys ea_id_obs: egen first_treat_wave = min(cond(treated_post==1, wave, .))
gen early_treat = (first_treat_wave==2)

keep if wave==1

collapse (mean) dist_tar_km dist_popcenter dist_market dist_admctr dist_urban_km ///
                 lan_productivity lab_productivity evi_peak mean_temp_c precip_ann_mm ///
         (max) early_treat zone_year, by(ea_id_obs)

eststo clear

foreach x in dist_tar_km dist_popcenter dist_market dist_admctr dist_urban_km {
    eststo A1_`x': reghdfe `x' early_treat, absorb(zone_year) vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("No") fe2("Yes")
}

esttab A1_dist_tar_km A1_dist_popcenter A1_dist_market A1_dist_admctr A1_dist_urban_km ///
    using "Table A1.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Asphalt road" "Population center" "Market" "Zonal capital" "Urban center") ///
    keep(early_treat) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table A1. Baseline Covariate Balance: Accessibility Measures") ///
    addnotes("Notes: Each column reports a separate baseline regression of the listed pre-treatment characteristic on an indicator for early treatment. The sample includes only enumeration areas that are eventually improved. All variables are measured at baseline. Standard errors are clustered at the enumeration-area level.")


*========================================================================================*
* Table A2. Baseline Covariate Balance: Productivity and Agro-Climatic Conditions
*========================================================================================*
eststo clear

foreach x in lan_productivity lab_productivity evi_peak mean_temp_c precip_ann_mm {
    eststo A2_`x': reghdfe `x' early_treat, absorb(zone_year) vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("No") fe2("Yes")
}

esttab A2_lan_productivity A2_lab_productivity A2_evi_peak A2_mean_temp_c A2_precip_ann_mm ///
    using "Table A2.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land productivity" "Labor productivity" "Vegetation index" "Temperature" "Precipitation") ///
    keep(early_treat) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table A2. Baseline Covariate Balance: Productivity and Agro-Climatic Conditions") ///
    addnotes("Notes: Each column reports a separate baseline regression of the listed pre-treatment characteristic on an indicator for early treatment. The sample includes only enumeration areas that are eventually improved. All variables are measured at baseline. Standard errors are clustered at the enumeration-area level.")


*========================================================================================*
* Table A3. Household-Level Heterogeneity with Controls
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo A5_`y': reghdfe `y' treated_post post_cert_t0 road_cert_t0 $controls if $mainsample, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("Yes") fe1("Yes") fe2("Yes")
}

esttab A5_abslog_mpL_gap A5_abslog_mpN_gap A5_abslog_mpK_gap A5_effgain_hh ///
    using "Table A3.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(treated_post post_cert_t0 road_cert_t0) ///
    order(treated_post post_cert_t0 road_cert_t0) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table A5. Household-Level Heterogeneity with Controls") ///
    addnotes("Notes: Each column reports a separate household-level regression with heterogeneity by baseline land certificate prevalence and additional controls. Controls include distance to the nearest asphalt road, peak vegetation index, mean temperature, and annual precipitation. The sample is restricted to enumeration areas that are eventually improved and to waves 1 and 2. Standard errors are clustered at the enumeration-area level.")


*========================================================================================*
* Table A4. Household-Level Misallocation in the Full Sample
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo A6_`y': reghdfe `y' treated_post, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

esttab A6_abslog_mpL_gap A6_abslog_mpN_gap A6_abslog_mpK_gap A6_effgain_hh ///
    using "Table A4.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(treated_post) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table A6. Household-Level Misallocation in the Full Sample") ///
    addnotes("Notes: Each column reports a separate household-level difference-in-differences regression using the full sample rather than restricting to eventually improved enumeration areas. Standard errors are clustered at the enumeration-area level.")

	
	
*========================================================================================*
* Table A5. Household-Level Heterogeneity in the Full Sample
*========================================================================================*
eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo A7_`y': reghdfe `y' treated_post post_cert_t0 road_cert_t0, ///
        $FE_ea_zone vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("Yes") fe2("Yes")
}

esttab A7_abslog_mpL_gap A7_abslog_mpN_gap A7_abslog_mpK_gap A7_effgain_hh ///
    using "Table A5.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(treated_post post_cert_t0 road_cert_t0) ///
    order(treated_post post_cert_t0 road_cert_t0) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone x year fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table A7. Household-Level Heterogeneity in the Full Sample") ///
    addnotes("Notes: Each column reports a separate household-level regression using the full sample rather than restricting to eventually improved enumeration areas. Baseline certificate share is measured before treatment. Standard errors are clustered at the enumeration-area level.")


	
*========================================================================================*
* Table A6. Baseline Certificate Share and Household-Level Misallocation
*========================================================================================*
use "misalloc_household.dta", clear
merge m:1 wave ea_id using "$road_treat", keep(3) nogen

eststo clear

foreach y in abslog_mpL_gap abslog_mpN_gap abslog_mpK_gap effgain_hh {
    eststo A8_`y': reghdfe `y' cert_share_t0 if wave==1, ///
        absorb(zone_year) vce(cluster ea_id_obs)
    add_table_rows, controls("No") fe1("No") fe2("Yes")
}

esttab A8_abslog_mpL_gap A8_abslog_mpN_gap A8_abslog_mpK_gap A8_effgain_hh ///
    using "Table A6.rtf", replace ///
    b(3) se(3) r2 obslast ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label nonumber compress nonotes ///
    mtitles("Land MP gap" "Labor MP gap" "Capital MP gap" "Efficiency gap") ///
    keep(cert_share_t0) ///
    stats(controls_row fe1_row fe2_row N r2, ///
        labels("Controls" "EA fixed effects" "Zone fixed effects" "Observations" "R-squared") ///
        fmt(0 0 0 0 3)) ///
    title("Table A8. Baseline Certificate Share and Household-Level Misallocation") ///
    addnotes("Notes: Each column reports a cross-sectional baseline regression using wave 1 only. The explanatory variable is the baseline share of households with land certificates in the enumeration area. Standard errors are clustered at the enumeration-area level.")



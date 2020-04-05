/***
* Name: Corona
* Author: hqngh
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model Corona

import "../Global.gaml"
import "../species/Policy.gaml"
import "Abstract Experiment.gaml"

experiment "Realistic Lockdown" parent: "Abstract Experiment" {
	map<string, unknown> ask_values {
		float p <- -1.0;
		map<string, unknown> result;
		loop while: (p > 1) or (p < 0) {
			result <- user_input("Initialization", ["Proportion (between 0 and 1) of essential workers allowed to go out"::0.1, "Daily number of tests"::300]);
			p <- float(result["Proportion (between 0 and 1) of essential workers allowed to go out"]);
		}

		return result;
	}

	action _init_ {
		map<string, unknown> input <- ask_values();
		float percentage_ <- float(input["Proportion (between 0 and 1) of essential workers allowed to go out"]);
		int number_of_tests_ <- int(input["Daily number of tests"]);
		create simulation {
			name <- "No containment policy";
			ask Authority {
				policy <- create_no_containment_policy();
			}

		}

		create simulation {
			name <- "Realistic lockdown with " + int(percentage_ * 100) + "% of essential workers and " + number_of_tests_ + " daily tests";
			transmission_building <- true;
			ask Authority {
				AbstractPolicy d <- create_detection_policy(number_of_tests_, false, true);
				AbstractPolicy l <- create_lockdown_policy_except([act_home, act_shopping]);
				AbstractPolicy p <- create_positive_at_home_policy();
				l <- with_percentage_of_allowed_individual(l, percentage_);
				policy <- combination([d, p, l]);
			}

		}

	}
	
	permanent {
		
		display "charts" toolbar: false background: #black{
			chart "Infected cases" background: #black axes: #white color: #white title_font: default legend_font: font("Helvetica", 14, #bold) {
			loop s over: simulations {
				data s.name value: s.number_of_infectious color: s.color marker: false style: line thickness: 2; 
				
			}}
		}
		
		display "Cumulative incidence" toolbar: false background: #black{
			chart "Cumulative incidence" background: #black axes: #white color: #white title_font: default legend_font: font("Helvetica", 14, #bold) {
			loop s over: simulations {
				data s.name value: s.total_number_of_infected color: s.color marker: false style: line thickness: 2; 
				
			}}
		}
	}

	output {
		layout #split consoles: false editors: false navigator: false tray: false tabs: false toolbars: false controls: false;
		
		display "Main" parent: default_display {
		}

	}

}


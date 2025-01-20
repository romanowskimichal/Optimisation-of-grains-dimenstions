function [Fuel_Input, Grain_Struct, Engine_Parameters, Ambient_Input, Simulation_Settings] = AA_GROT_Input()

Fuel_Input.propellant_name = "GROT-fuel";              %Name of the propellant
Fuel_Input.propellant_density = 1769;        	        %Propellant density [kg/m^3]
Fuel_Input.temperature_combustion = 2300;           	%Combustion temperature [K]
Fuel_Input.kappa = 1.1996;                             	%Heat Capacity Ratio [-]
Fuel_Input.molar_mass = 26.621;                        	%Molar mass of combustion products [g/mol]
Fuel_Input.burn_coefficient = 3.45441;                   	%Temperature coefficient [mm/s]
Fuel_Input.burn_expo = 0.360751;                        	%Burn rate exponent [-]

%Data for pressure dependent burn coefficients- all the values here are just placeholders
Fuel_Input.coeffs_ranges = [2; 5];                 % Values of pressures at which, burn coefficients changes [MPa] 
Fuel_Input.burn_coefficients = [2.5; 3.25; 5];     % Values of burn coelfficients in following ranges
Fuel_Input.burn_expos = [0.35; 0.45; 0.6];

%%Erosive burn constants (szymon has to check it for final approval)
Fuel_Input.dynamic_viscosity = 0.76789 * 10^-4;			%Dynamic viscocity [Pa*s]
Fuel_Input.conductivity = 0.25523;                      %Heat conductivity of gas [W/m/K]
Fuel_Input.C_p = 1915.2;                %Fuel_Input.gas_constant * Fuel_Input.kappa / (Fuel_Input.kappa - 1); 	%Gas heat capacity [J/kg/K]
Fuel_Input.Pr = 0.5762;                 %Fuel_Input.dynamic_viscosity * Fuel_Input.C_p / Fuel_Input.conductivity; 		%Prandtl's number [-]
Fuel_Input.C_pr = 2100; 				%Specfic heat [J/kg/K]
Fuel_Input.linear_coeff = 0.0288;       %linear coefficient in >alpha< equation in erosive burn
Fuel_Input.beta = 98.7773;                  %erosive constant [-]
Fuel_Input.Ts = 1100; 					%temperature of propellant's surface [K]

grain_number = 1;
Grain_Struct(grain_number).x_grain_base_wrt_nozzle_inlet = 0.0035;
Grain_Struct(grain_number).Grain_stl_filename = '/InputFiles/STL/G.1.02.05.002_Propellant_rotatedv2.stl';
Grain_Struct(grain_number).Inhibition.top_inhibited = false;
Grain_Struct(grain_number).Inhibition.bottom_inhibited = false;
Grain_Struct(grain_number).Inhibition.outer_inhibited = true;
Grain_Struct(grain_number).Inhibition.inner_inhibited = false;
Grain_Struct(grain_number).geometry_type = 2;%'periodic_symmetric';
Grain_Struct(grain_number).period_instances = 8;     
Grain_Struct(grain_number).slice_height = 0.002;
Grain_Struct(grain_number).constant_cross_section = false;
Grain_Struct(grain_number).grain_reversed = 0;

Ambient_Input.pressure = 0.1;                           %Ambient pressure[MPa]
Ambient_Input.temperature = 293.0;                      %Ambient temperature[K]

Engine_Parameters.Chamber_Input.volume = 0.005588422;                         %Chamber volume [m^3] calculated from CAD model 
Engine_Parameters.Chamber_Input.crosssection_area = pi*0.059^2;              %Chamber cross-section area [m^3]
Engine_Parameters.Chamber_Input.initial_pressure = Ambient_Input.pressure;

Engine_Parameters.Nozzle_Input.shape_case = "conical";                   %Type of the nozzle used
Engine_Parameters.Nozzle_Input.entry_diameter = 0.11;                        %Diameter [m] of nozzle entry
Engine_Parameters.Nozzle_Input.throat_diameter = 0.0295;                      %Diameter [m] of nozzle throat
Engine_Parameters.Nozzle_Input.exit_diameter = 0.0821;                         %Diameter [m] of nozzle exit
Engine_Parameters.Nozzle_Input.throat_rounding_radius_1 = 0.008;              %Radius [m] of the rounding before the nozzle throat
Engine_Parameters.Nozzle_Input.throat_rounding_radius_2 = 0.018;              %Radius [m] of the rounding after the nozzle throat
Engine_Parameters.Nozzle_Input.convergent_length = 0.0459;                       %Distance [m] from the nozzle entry to the nozzle throat
Engine_Parameters.Nozzle_Input.throat_length = 0.0136;                          %Length [m] of the constant diameter section before nozzle throat
Engine_Parameters.Nozzle_Input.divergent_length = 0.1041;                       %Distance [m] from the nozzle throat to the nozzle exit
Engine_Parameters.Nozzle_Input.efficiency = 0.99;                             %Nozzle efficiency [-]
Engine_Parameters.Nozzle_Input.erosion_func = '0.003/(3.25)^2*x^2 + 0.0372';  %symbolic representatnion of nozzle erosion (borrowed from TuCAN) 
 
Simulation_Settings.time_step = 0.001;                %Time step for calculations [s]
Simulation_Settings.solver_type = 'euler';
Simulation_Settings.time_max = 10;                     %Simulation time [s]
Simulation_Settings.reporting_interval = 0;
Simulation_Settings.Booleans.enable_erosive_burning = true;
Simulation_Settings.Booleans.perform_3D_visualisation = false;  %Boolean operator for performing visualisation
Simulation_Settings.Booleans.perform_nozzle_optimization = false;
Simulation_Settings.Booleans.enable_nozzle_erosion = false;                        %flag which enables nozzle erosion
Simulation_Settings.Booleans.thrust_pressure_term = true;
Simulation_Settings.Booleans.pressure_dependent_burn_coeffs = false;
Simulation_Settings.Booleans.draw_plots = true;
Simulation_Settings.Booleans.generate_output_all = true;                    %The big txt file
Simulation_Settings.Booleans.generate_rfs_input = true;
Simulation_Settings.Booleans.generate_output_short = true;                  %The file with average values, like the one Szymon sent (BOSSMAN.out).
Simulation_Settings.Booleans.display_output_short = true;
Simulation_Settings.Booleans.load_grain_struct = false;                      %if false - read .stl; if true - read .mat Grain_Struct
Simulation_Settings.Booleans.hybrid_engine = false;
Simulation_Settings.Booleans.enable_waitbar = true;
Simulation_Settings.Booleans.running_nozzle_optimization = false;
Simulation_Settings.Booleans.correction_factors = true;                    %The effect of the angular divergence of the nozzle exit flow on thrust
Simulation_Settings.grain_struct_path = 'InputFiles/Grains/GROT_periodic_symmetric-Grain_Struct.mat';

Simulation_Settings.Plots_Settings.cross_section_visualisation = false;
Simulation_Settings.Plots_Settings.live_thrust_plot = false; 
Simulation_Settings.Plots_Settings.burn_area = true;
Simulation_Settings.Plots_Settings.burn_rate = true;
Simulation_Settings.Plots_Settings.volume = true;
Simulation_Settings.Plots_Settings.nozzle_mass_flow = true;
Simulation_Settings.Plots_Settings.produced_mass_flow = true;
Simulation_Settings.Plots_Settings.pressure = true;
Simulation_Settings.Plots_Settings.dV = true;
Simulation_Settings.Plots_Settings.dVdt = true;
Simulation_Settings.Plots_Settings.thrust = true;
Simulation_Settings.Plots_Settings.inertia = true;
Simulation_Settings.Plots_Settings.klemmung = true;
Simulation_Settings.Plots_Settings.exit_pressure = true;
Simulation_Settings.Plots_Settings.exit_temperature = true;
Simulation_Settings.Plots_Settings.exit_velocity = true;
Simulation_Settings.Plots_Settings.exit_mach = true;
Simulation_Settings.Plots_Settings.throat_pressure = true;
Simulation_Settings.Plots_Settings.throat_temperature = true;
Simulation_Settings.Plots_Settings.throat_velocity = true;
Simulation_Settings.Plots_Settings.display_events = false;

Simulation_Settings.Cross_Section_Visualisation.grain_number = 1;
Simulation_Settings.Cross_Section_Visualisation.slice_number = 2137;

Simulation_Settings.Visualisation_Settings.auto_range_colorbar = false;    % Should auto range be performed on colorbar or not?
Simulation_Settings.Visualisation_Settings.video_speed = 1.0;                % Value greater than 0 controlling the speed of visualisation video, 1 is normal speed, >1 is faster
Simulation_Settings.Visualisation_Settings.control_frame_rate = 0;     %Frame rate for writing of video
Simulation_Settings.Visualisation_Settings.frame_rate = 2;                %Frame rate for writing of video
Simulation_Settings.Visualisation_Settings.max_velocity = 500;            %Maximum motor velocity attainable

Simulation_Settings.Optimization_Input.throat_tolerance = 0.0005;         %Tolerance of optimization[m]
Simulation_Settings.Optimization_Input.exit_tolerance = 0.001;            %Tolerance of optimization[m]
Simulation_Settings.Optimization_Input.allowed_pressure = 7.5;            %Maximum working pressure [MPa]
Simulation_Settings.Optimization_Input.upper_bound = 0.02137;%PLACEHOLDER  2 * max(Grain_Input.outer_radius) 
end

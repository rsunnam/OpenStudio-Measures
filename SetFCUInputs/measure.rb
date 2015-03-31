#start the measure
class SetFCUInputs < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "Set FCU Inputs"
  end

  #define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    #TODO
    # add other inputs
    # more elegant way of selecting which inputs are active

    #string
    string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", false)
		string.setDisplayName("Set inputs for FCUs containing the string (case sensitive). Enter *.* for all FCUs.")
    string.setDefaultValue("*.*")
		args << string
'
ZoneHVAC:FourPipeFanCoil,
    ,                        !- Name
    ,                        !- Availability Schedule Name
    ,                        !- Capacity Control Method
    ,                        !- Maximum Supply Air Flow Rate {m3/s}
    0.33,                    !- Low Speed Supply Air Flow Ratio
    0.66,                    !- Medium Speed Supply Air Flow Ratio
    ,                        !- Maximum Outdoor Air Flow Rate {m3/s}
    ,                        !- Outdoor Air Schedule Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Outdoor Air Mixer Object Type
    ,                        !- Outdoor Air Mixer Name
    ,                        !- Supply Air Fan Object Type
    ,                        !- Supply Air Fan Name
    ,                        !- Cooling Coil Object Type
    ,                        !- Cooling Coil Name
    ,                        !- Maximum Cold Water Flow Rate {m3/s}
    ,                        !- Minimum Cold Water Flow Rate {m3/s}
    0.001,                   !- Cooling Convergence Tolerance
    ,                        !- Heating Coil Object Type
    ,                        !- Heating Coil Name
    ,                        !- Maximum Hot Water Flow Rate {m3/s}
    ,                        !- Minimum Hot Water Flow Rate {m3/s}
    0.001,                   !- Heating Convergence Tolerance
    ,                        !- Availability Manager List Name
    1;                       !- Design Specification ZoneHVAC Sizing Object Name
'
    # FCU Inputs

    # capacity control method

    fcu_sa_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_sa_flow", false)
    fcu_sa_flow.setDisplayName("FCU: Maximum Supply Air Flow Rate {ft3/min}")
    fcu_sa_flow.setDefaultValue(-1)
    args << fcu_sa_flow

    fcu_oa_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fcu_oa_flow", false)
    fcu_oa_flow.setDisplayName("FCU: Maximum Outdoor Air Flow Rate {ft3/min}")
    fcu_oa_flow.setDefaultValue(-1)
    args << fcu_oa_flow

    #fcu_oa_sched

    fcu_max_cw_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("max_cw", false)
    max_cw.setDisplayName("FCU: Maximum Cold Water Flow Rate {gal/min}")
    max_cw.setDefaultValue(-1)
    args << max_cw

    #fcu_min_cw_flow

    fcu_max_hw_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("max_hw", false)
    max_hw.setDisplayName("FCU: Maximum Hot Water Flow Rate {gal/min}")
    max_hw.setDefaultValue(-1)
    args << max_hw

    #fcu_min_hw_flow
'
Fan:ConstantVolume,
    FanConstantVolume,       !- Name
    ,                        !- Availability Schedule Name
    0.7,                     !- Fan Total Efficiency
    ,                        !- Pressure Rise {Pa}
    ,                        !- Maximum Flow Rate {m3/s}
    0.9,                     !- Motor Efficiency
    1,                       !- Motor In Airstream Fraction
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    General;                 !- End-Use Subcategory
'
    # Fan Inputs - TODO add all types when available: OnOff, CAV, VAV

    fan_tot_eff = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_tot_eff", false)
    fan_tot_eff.setDisplayName("Fan: Fan Total Efficiency")
    fan_tot_eff.setDefaultValue(-1)
    args << fan_tot_eff

    fan_rise = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_rise", false)
    fan_rise.setDisplayName("Fan: Pressure Rise {inH2O}")
    fan_rise.setDefaultValue(-1)
    args << fan_rise

    fan_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_flow", false)
    fan_flow.setDisplayName("Fan: Maximum Flow Rate {ft3/min}")
    fan_flow.setDefaultValue(-1)
    args << fan_flow

    fan_mot_eff = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_mot_eff", false)
    fan_mot_eff.setDisplayName("Fan:Motor Efficiency")
    fan_mot_eff.setDefaultValue(-1)
    args << fan_mot_eff

'
Coil:Cooling:Water,
    CoilCoolingWater,        !- Name
    ,                        !- Availability Schedule Name
    autosize,                !- Design Water Flow Rate {m3/s}
    autosize,                !- Design Air Flow Rate {m3/s}
    autosize,                !- Design Inlet Water Temperature {C}
    autosize,                !- Design Inlet Air Temperature {C}
    autosize,                !- Design Outlet Air Temperature {C}
    autosize,                !- Design Inlet Air Humidity Ratio {kgWater/kgDryAir}
    autosize,                !- Design Outlet Air Humidity Ratio {kgWater/kgDryAir}
    ,                        !- Water Inlet Node Name
    ,                        !- Water Outlet Node Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    SimpleAnalysis,          !- Type of Analysis
    CounterFlow,             !- Heat Exchanger Configuration
    0;                       !- Condensate Collection Water Storage Tank Name
'
    # Clg Coil Inputs

    cc_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_wtr_flow", false)
    cc_wtr_flow.setDisplayName("Clg Coil: Design Water Flow Rate {ft3/min}")
    cc_wtr_flow.setDefaultValue(-1)
    args << cc_wtr_flow

    cc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_air_flow", false)
    cc_air_flow.setDisplayName("Clg Coil: Design Air Flow Rate {ft3/min}")
    cc_air_flow.setDefaultValue(-1)
    args << cc_air_flow

    cc_ewt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_ewt", false)
    cc_ewt.setDisplayName("Clg Coil: Design Inlet Water Temperature {F}")
    cc_ewt.setDefaultValue(-1)
    args << cc_ewt

    cc_eat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_eat", false)
    cc_eat.setDisplayName("Clg Coil: Design Inlet Air Temperature {F}")
    cc_eat.setDefaultValue(-1)
    args << cc_eat

    cc_lat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_lat", false)
    cc_lat.setDisplayName("Clg Coil: Design Outlet Air Temperature {F}")
    cc_lat.setDefaultValue(-1)
    args << cc_lat

    #cc_w_in
'
Coil:Heating:Water,
    CoilHeatingWater,        !- Name
    ,                        !- Availability Schedule Name
    autosize,                !- U-Factor Times Area Value {W/K}
    autosize,                !- Maximum Water Flow Rate {m3/s}
    ,                        !- Water Inlet Node Name
    ,                        !- Water Outlet Node Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    UFactorTimesAreaAndDesignWaterFlowRate,  !- Performance Input Method
    autosize,                !- Rated Capacity {W}
    82.2,                    !- Rated Inlet Water Temperature {C}
    16.6,                    !- Rated Inlet Air Temperature {C}
    71.1,                    !- Rated Outlet Water Temperature {C}
    32.2,                    !- Rated Outlet Air Temperature {C}
    0.5;                     !- Rated Ratio for Air and Water Convection
'
    # Htg Coil Inputs

    hc_ua = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_ua", false)
    hc_ua.setDisplayName("Htg Coil: U-Factor Times Area Value {Btu/h-R}")
    hc_ua.setDefaultValue(-1)
    args << hc_ua

    hc_max_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_max_wtr_flow", false)
    hc_max_wtr_flow.setDisplayName("Htg Coil: Maximum Water Flow Rate {ft3/min}")
    hc_max_wtr_flow.setDefaultValue(-1)
    args << hc_max_wtr_flow

    hc_perf_choices = OpenStudio::StringVector.new
    hc_perf_choices << "Nominal Capacity"
    hc_perf_choices << "UFactorTimesAreaAndDesignWaterFlowRate"
    hc_perf = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("hc_perf", hc_perf_choices, true)
    hc_perf.setDisplayName("Htg Coil: Performance Input Method")
    hc_perf.setDefaultValue("UFactorTimesAreaAndDesignWaterFlowRate")
    args << hc_perf

    hc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_cap", false)
    hc_cap.setDisplayName("Htg Coil: Rated Capacity {Btu/h}")
    hc_cap.setDefaultValue(-1)
    args << hc_cap

    hc_ewt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_ewt", false)
    hc_ewt.setDisplayName("Htg Coil: Rated Inlet Water Temperature {F}")
    hc_ewt.setDefaultValue(-1)
    args << hc_ewt

    hc_eat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_eat", false)
    hc_eat.setDisplayName("Htg Coil: Rated Inlet Air Temperature {F}")
    hc_eat.setDefaultValue(-1)
    args << hc_eat

    hc_lwt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_lwt", false)
    hc_lwt.setDisplayName("Htg Coil: Rated Outlet Water Temperature {F}")
    hc_lwt.setDefaultValue(-1)
    args << hc_lwt

    hc_lat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_lat", false)
    hc_lat.setDisplayName("Htg Coil: Rated Outlet Air Temperature {F}")
    hc_lat.setDefaultValue(-1)
    args << hc_lat

    return args

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign user inputs to variables, convert from strings to floating point, convert to SI units
    string = runner.getStringArgumentValue("string", user_arguments)
    # fcu
    fcu_flow = runner.getDoubleArgumentValue("fcu_flow", user_arguments)
    fcu_flow_si = OpenStudio.convert(fcu_flow, "ft^3/min", "m^3/s").get
    fcu_oa = runner.getDoubleArgumentValue("fcu_oa", user_arguments)
    fcu_oa_si = OpenStudio.convert(fcu_oa, "ft^3/min", "m^3/s").get
    # fan
    fan_flow = runner.getDoubleArgumentValue("fan_flow", user_arguments)
    fan_flow_si = OpenStudio.convert(fan_flow, "ft^3/min", "m^3/s").get
    fan_rise = runner.getDoubleArgumentValue("fan_rise", user_arguments)
    fan_rise_si = OpenStudio.convert(fan_rise, "inH_{2}O", "Pa").get
    # clg coil
    cc_ewt = runner.getDoubleArgumentValue("cc_ewt", user_arguments)
    cc_ewt_si = OpenStudio.convert(cc_ewt, "F", "C").get
    cc_eat = runner.getDoubleArgumentValue("cc_eat", user_arguments)
    cc_eat_si = OpenStudio.convert(cc_eat, "F", "C").get
    cc_lat = runner.getDoubleArgumentValue("cc_lat", user_arguments)
    cc_lat_si = OpenStudio.convert(cc_lat, "F", "C").get
    # htg coil
    hc_ewt = runner.getDoubleArgumentValue("hc_ewt", user_arguments)
    hc_ewt_si = OpenStudio.convert(hc_ewt, "F", "C").get
    hc_eat = runner.getDoubleArgumentValue("hc_eat", user_arguments)
    hc_eat_si = OpenStudio.convert(hc_eat, "F", "C").get
    hc_lwt = runner.getDoubleArgumentValue("hc_lwt", user_arguments)
    hc_lwt_si = OpenStudio.convert(hc_lwt, "F", "C").get
    hc_lat = runner.getDoubleArgumentValue("hc_lat", user_arguments)
    hc_lat_si = OpenStudio.convert(hc_lat, "F", "C").get

    # MAIN BLOCK

    # get model objects
    fcus = model.getZoneHVACFourPipeFanCoils
    fans = model.getFanConstantVolumes #as of version 1.5.0 FCUs are limited to CAV fans which are automatically created
    clg_coils = model.getCoilCoolingWaters
    htg_coils = model.getCoilHeatingWaters

    # initial conditions
    runner.registerInitialCondition("Number of FCUs in the model = #{fcus.size}")

    # initialize reporting variables
    n_fcus = 0
    error = false

    fcus.each do |fcu|

      if fcu.name.to_s.include? string or string == "*.*"
        runner.registerInfo("Setting #{fcu.name} fields")

        # get fcu components
        fan = fcu.supplyAirFan.to_FanConstantVolume.get #TODO - add other types for v1.7
        clg_coil = fcu.coolingCoil.to_CoilCoolingWater.get
        htg_coil = fcu.heatingCoil.to_CoilHeatingWater.get

        # set FCU fields
        if fcu_flow_si > 0
          fcu.setMaximumSupplyAirFlowRate(fcu_flow_si)
        end
        if fcu_oa_si > 0
          fcu.setMaximumOutdoorAirFlowRate(fcu_oa_si)
        end

        # set fan fields
        if fan_flow_si > 0
          fan.setMaximumFlowRate(fan_flow_si)
        end
        if fan_rise_si > 0
          fan.setPressureRise(fan_rise_si)
        end

        # set clg coil fields
        if cc_ewt_si > 0
          clg_coil.setDesignInletWaterTemperature(cc_ewt_si)
        end
        if cc_eat_si > 0
          clg_coil.setDesignInletAirTemperature(cc_eat_si)
        end
        if cc_lat_si > 0
          clg_coil.setDesignOutletAirTemperature(cc_lat_si)
        end

        # set htg coil fields
        if hc_ewt_si > 0
          htg_coil.setRatedInletWaterTemperature(hc_ewt_si)
        end
        if hc_eat_si > 0
          htg_coil.setRatedInletAirTemperature(hc_eat_si)
        end
        if hc_lwt_si > 0
          htg_coil.setRatedOutletWaterTemperature(hc_lwt_si)
        end
        if hc_lat_si > 0
          htg_coil.setRatedOutletAirTemperature(hc_lat_si)
        end

        n_fcus += 1

      else

        error = true

      end

    end

    if error == true
      runner.registerError("String not found.")
    end

    # final conditions
    runner.registerFinalCondition("Number of FCUs changed = #{n_fcus}")

    return true

  end #end the run method

end #end the measure

#this allows the measure to be use by the application
SetFCUInputs.new.registerWithApplication

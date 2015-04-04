#start the measure
class SetFCUInputs < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return 'Set FCU Inputs'
  end

  #define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    # OS version = 1.7.0
    # EP version = 8.2.0

    #string
    string = OpenStudio::Ruleset::OSArgument::makeStringArgument('string', false)
		string.setDisplayName('Set inputs for equipment containing the string (case sensitive). Enter *.* for all FCUs.')
    string.setDefaultValue('*.*')
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
    # fcu arguments

    fcu_sched = nil

    fcu_method = nil

    fcu_sa_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_sa_flow', false)
    fcu_sa_flow.setDisplayName('FCU: Maximum Supply Air Flow Rate {ft3/min}')
    fcu_sa_flow.setDefaultValue(-1)
    args << fcu_sa_flow

    fcu_sa_rat_low = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_sa_rat_low', false)
    fcu_sa_rat_low.setDisplayName('FCU: Low Speed Supply Air Flow Ratio')
    fcu_sa_rat_low.setDefaultValue(-1)
    args << fcu_sa_rat_low

    fcu_sa_rat_med = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_sa_rat_med', false)
    fcu_sa_rat_med.setDisplayName('FCU: Medium Speed Supply Air Flow Ratio')
    fcu_sa_rat_med.setDefaultValue(-1)
    args << fcu_sa_rat_med

    fcu_oa_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_oa_flow', false)
    fcu_oa_flow.setDisplayName('FCU: Maximum Outdoor Air Flow Rate {ft3/min}')
    fcu_oa_flow.setDefaultValue(-1)
    args << fcu_oa_flow

    fcu_oa_sched = nil

    fcu_cw_flow_max = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_cw_flow_max', false)
    fcu_cw_flow_max.setDisplayName('FCU: Maximum Cold Water Flow Rate {gal/min}')
    fcu_cw_flow_max.setDefaultValue(-1)
    args << fcu_cw_flow_max

    fcu_cw_flow_min = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_cw_flow_min', false)
    fcu_cw_flow_min.setDisplayName('FCU: Minimum Cold Water Flow Rate {gal/min}')
    fcu_cw_flow_min.setDefaultValue(-1)
    args << fcu_cw_flow_min

    fcu_clg_tol = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_clg_tol', false)
    fcu_clg_tol.setDisplayName('FCU: Cooling Convergence Tolerance')
    fcu_clg_tol.setDefaultValue(-1)
    args << fcu_clg_tol

    fcu_max_hw_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_max_hw_flow', false)
    fcu_max_hw_flow.setDisplayName('FCU: Maximum Hot Water Flow Rate {gal/min}')
    fcu_max_hw_flow.setDefaultValue(-1)
    args << fcu_max_hw_flow

    fcu_min_hw_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_min_hw_flow', false)
    fcu_min_hw_flow.setDisplayName('FCU: Maximum Hot Water Flow Rate {gal/min}')
    fcu_min_hw_flow.setDefaultValue(-1)
    args << fcu_min_hw_flow

    fcu_htg_tol = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fcu_htg_tol', false)
    fcu_htg_tol.setDisplayName('FCU: Cooling Convergence Tolerance')
    fcu_htg_tol.setDefaultValue(-1)
    args << fcu_htg_tol
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
    # clg coil arguments

    cc_sched = nil

    cc_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('cc_wtr_flow', false)
    cc_wtr_flow.setDisplayName('Clg Coil: Design Water Flow Rate {ft3/min}')
    cc_wtr_flow.setDefaultValue(-1)
    args << cc_wtr_flow

    cc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('cc_air_flow', false)
    cc_air_flow.setDisplayName('Clg Coil: Design Air Flow Rate {ft3/min}')
    cc_air_flow.setDefaultValue(-1)
    args << cc_air_flow

    cc_ewt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('cc_ewt', false)
    cc_ewt.setDisplayName('Clg Coil: Design Inlet Water Temperature {F}')
    cc_ewt.setDefaultValue(-1)
    args << cc_ewt

    cc_eat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('cc_eat', false)
    cc_eat.setDisplayName('Clg Coil: Design Inlet Air Temperature {F}')
    cc_eat.setDefaultValue(-1)
    args << cc_eat

    cc_lat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('cc_lat', false)
    cc_lat.setDisplayName('Clg Coil: Design Outlet Air Temperature {F}')
    cc_lat.setDefaultValue(-1)
    args << cc_lat

    cc_humrat_in = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('cc_humrat_in', false)
    cc_humrat_in.setDisplayName('Clg Coil: Design Inlet Air Humidity Ratio')
    cc_humrat_in.setDefaultValue(-1)
    args << cc_humrat_in

    cc_humrat_out = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('cc_humrat_out', false)
    cc_humrat_out.setDisplayName('Clg Coil: Design Outlet Air Humidity Ratio')
    cc_humrat_out.setDefaultValue(-1)
    args << cc_humrat_out

    cc_analysis_choices = OpenStudio::StringVector.new
    cc_analysis_choices << 'DetailedAnalysis'
    cc_analysis_choices << 'SimpleAnalysis'
    cc_analysis = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('cc_analysis', cc_analysis_choices, true)
    cc_analysis.setDisplayName('Type of Analysis')
    cc_analysis.setDefaultValue('SimpleAnalysis')
    args << cc_analysis

    cc_config_choices = OpenStudio::StringVector.new
    cc_config_choices << 'CrossFlow'
    cc_config_choices << 'CounterFlow'
    cc_config = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('cc_config', cc_config_choices, true)
    cc_config.setDisplayName('Heat Exchanger Configuration')
    cc_config.setDefaultValue('CounterFlow')
    args << cc_config
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
    # htg coil arguments

    hc_sched = nil

    hc_ua = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_ua', false)
    hc_ua.setDisplayName('Htg Coil: U-Factor Times Area Value {Btu/h-R}')
    hc_ua.setDefaultValue(-1)
    args << hc_ua

    hc_wtr_flow_max = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_wtr_flow_max', false)
    hc_wtr_flow_max.setDisplayName('Htg Coil: Maximum Water Flow Rate {ft3/min}')
    hc_wtr_flow_max.setDefaultValue(-1)
    args << hc_wtr_flow_max

    hc_perf_choices = OpenStudio::StringVector.new
    hc_perf_choices << 'Nominal Capacity'
    hc_perf_choices << 'UFactorTimesAreaAndDesignWaterFlowRate'
    hc_perf = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('hc_perf', hc_perf_choices, true)
    hc_perf.setDisplayName('Htg Coil: Performance Input Method')
    hc_perf.setDefaultValue('UFactorTimesAreaAndDesignWaterFlowRate')
    args << hc_perf

    hc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_cap', false)
    hc_cap.setDisplayName('Htg Coil: Rated Capacity {Btu/h}')
    hc_cap.setDefaultValue(-1)
    args << hc_cap

    hc_ewt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_ewt', false)
    hc_ewt.setDisplayName('Htg Coil: Rated Inlet Water Temperature {F}')
    hc_ewt.setDefaultValue(-1)
    args << hc_ewt

    hc_eat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_eat', false)
    hc_eat.setDisplayName('Htg Coil: Rated Inlet Air Temperature {F}')
    hc_eat.setDefaultValue(-1)
    args << hc_eat

    hc_lwt = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_lwt', false)
    hc_lwt.setDisplayName('Htg Coil: Rated Outlet Water Temperature {F}')
    hc_lwt.setDefaultValue(-1)
    args << hc_lwt

    hc_lat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_lat', false)
    hc_lat.setDisplayName('Htg Coil: Rated Outlet Air Temperature {F}')
    hc_lat.setDefaultValue(-1)
    args << hc_lat

    hc_conv_ratio = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('hc_conv_ratio', false)
    hc_conv_ratio.setDisplayName('Htg Coil: Rated Ratio for Air and Water Convection')
    hc_conv_ratio.setDefaultValue(-1)
    args << hc_conv_ratio

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
    string = runner.getStringArgumentValue('string', user_arguments)

    #fcu_sched = TODO
    fcu_sa_flow = runner.getDoubleArgumentValue('fcu_sa_flow', user_arguments)
    fcu_sa_flow_si = OpenStudio.convert(fcu_sa_flow, 'ft^3/min', 'm^3/s').get
    fcu_sa_rat_low = runner.getDoubleArgumentValue('fcu_sa_rat_low', user_arguments)
    fcu_sa_rat_med = runner.getDoubleArgumentValue('fcu_sa_rat_med', user_arguments)
    fcu_oa_flow = runner.getDoubleArgumentValue('fcu_oa_flow', user_arguments)
    fcu_oa_flow_si = OpenStudio.convert(fcu_oa_flow, 'ft^3/min', 'm^3/s').get
    #fcu_oa_sched = TODO
    fcu_cw_flow_max = runner.getDoubleArgumentValue('fcu_cw_flow_max', user_arguments)
    fcu_cw_flow_max_si = OpenStudio.convert(fcu_cw_flow_max, 'gal/min', 'm^3/s').get
    fcu_cw_flow_min = runner.getDoubleArgumentValue('fcu_cw_flow_min', user_arguments)
    fcu_cw_flow_min_si = OpenStudio.convert(fcu_cw_flow_min, 'gal/min', 'm^3/s').get
    fcu_clg_tol = runner.getDoubleArgumentValue('fcu_clg_tol', user_arguments)
    fcu_hw_flow_max = runner.getDoubleArgumentValue('fcu_hw_flow_max', user_arguments)
    fcu_hw_flow_max_si = OpenStudio.convert(fcu_hw_flow_max, 'gal/min', 'm^3/s').get
    fcu_hw_flow_min = runner.getDoubleArgumentValue('fcu_hw_flow_min', user_arguments)
    fcu_hw_flow_min_si = OpenStudio.convert(fcu_hw_flow_min, 'gal/min', 'm^3/s').get
    fcu_htg_tol = runner.getDoubleArgumentValue('fcu_htg_tol', user_arguments)

    #cc_sched = TODO
    cc_wtr_flow = runner.getDoubleArgumentValue('cc_wtr_flow', user_arguments)
    cc_wtr_flow_si = OpenStudio.convert(cc_wtr_flow, 'gal/min', 'm^3/s').get
    cc_air_flow = runner.getDoubleArgumentValue('cc_air_flow', user_arguments)
    cc_air_flow_si = OpenStudio.convert(cc_air_flow, 'ft^2/min', 'm^3/s').get
    cc_ewt = runner.getDoubleArgumentValue('cc_ewt', user_arguments)
    cc_ewt_si = OpenStudio.convert(cc_ewt, 'F', 'C').get
    cc_eat = runner.getDoubleArgumentValue('cc_eat', user_arguments)
    cc_eat_si = OpenStudio.convert(cc_eat, 'F', 'C').get
    cc_lat = runner.getDoubleArgumentValue('cc_lat', user_arguments)
    cc_lat_si = OpenStudio.convert(cc_lat, 'F', 'C').get
    cc_humrat_in = runner.getDoubleArgumentValue('cc_humrat_in', user_arguments)
    cc_humrat_out = runner.getDoubleArgumentValue('cc_humrat_out', user_arguments)
    cc_analysis = runner.getStringArgumentValue('cc_analysis', user_arguments)
    cc_config = runner.getStringArgumentValue('cc_config', user_arguments)

    #hc_sched = TODO
    hc_ua = runner.getDoubleArgumentValue('hc_ua', user_arguments)
    hc_ua_si = OpenStudio.convert(hc_ua, 'Btu/hF', 'W/K').get
    hc_wtr_flow_max = runner.getDoubleArgumentValue('hc_wtr_flow_max', user_arguments)
    hc_wtr_flow_max_si = OpenStudio.convert(hc_wtr_flow_max, 'gal/min', 'm^3/s').get
    hc_perf = runner.getStringArgumentValue('hc_perf', user_arguments)
    hc_cap = runner.getDoubleArgumentValue('hc_cap', user_arguments)
    hc_cap_si = OpenStudio.convert(hc_cap, 'Btu/h', 'W').get
    hc_ewt = runner.getDoubleArgumentValue('hc_ewt', user_arguments)
    hc_ewt_si = OpenStudio.convert(hc_ewt, 'F', 'C').get
    hc_eat = runner.getDoubleArgumentValue('hc_eat', user_arguments)
    hc_eat_si = OpenStudio.convert(hc_eat, 'F', 'C').get
    hc_lwt = runner.getDoubleArgumentValue('hc_lwt', user_arguments)
    hc_lwt_si = OpenStudio.convert(hc_lwt, 'F', 'C').get
    hc_lat = runner.getDoubleArgumentValue('hc_lat', user_arguments)
    hc_lat_si = OpenStudio.convert(hc_lat, 'F', 'C').get
    hc_conv_ratio = runner.getDoubleArgumentValue('hc_conv_ratio', user_arguments)

    # MAIN BLOCK

    # get model objects
    fcus = model.getZoneHVACFourPipeFanCoils
    clg_coils = model.getCoilCoolingWaters
    htg_coils = model.getCoilHeatingWaters

    # initial conditions
    runner.registerInitialCondition('Number of FCUs in the model = #{fcus.size}')

    # initialize variables
    counter = 0
    error = false

    fcus.each do |fcu|

      if fcu.name.to_s.include? string or string == '*.*'
        runner.registerInfo('Setting #{fcu.name} fields')

        # getcomponents
        cc = fcu.coolingCoil.to_CoilCoolingWater.get
        hc = fcu.heatingCoil.to_CoilHeatingWater.get

        # set fcu fields
        #if fcu_sched TODO
        if fcu_sa_flow > 0
          fcu.setMaximumSupplyAirFlowRate(fcu_sa_flow_si)
        end
        if fcu_sa_rat_low > 0
          fcu.setLowSpeedSupplyAirFlowRatio(fcu_sa_rat_low)
        end
        if fcu_sa_rat_med > 0
          fcu.setMediumSpeedSupplyAirFlowRatio(fcu_sa_rat_med)
        end
        if fcu_oa_flow > 0
          fcu.setMaximumOutdoorAirFlowRate(fcu_oa_flow_si)
        end
        #if fcu_oa_sched TODO fcu.setOutdoorAirSchedule()
        if fcu_cw_flow_max > 0
          fcu.setMaximumColdWaterFlowRate(fcu_cw_flow_max_si)
        end
        if fcu_cw_flow_min > 0
          fcu.setMinimumColdWaterFlowRate(fcu_cw_flow_min_si)
        end
        if fcu_clg_tol > 0
          fcu.setCoolingConvergenceTolerance(fcu_clg_tol)
        end
        if fcu_hw_flow_max > 0
          fcu.setMaximumHotWaterFlowRate(fcu_hw_flow_max_si)
        end
        if fcu_hw_flow_min > 0
          fcu.setMinimumHotWaterFlowRate(fcu_hw_flow_min_si)
        end
        if fcu_htg_tol > 0
          fcu.setHeatingConvergenceTolerance(fcu_htg_tol)
        end

        # set clg coil fields
        #if cc_sched TODO
        if cc_wtr_flow > 0
          cc.setDesignWaterFlowRate(cc_wtr_flow_si)
        end
        if cc_air_flow > 0
          cc.setDesignAirFlowRate(cc_air_flow_si)
        end
        if cc_ewt_si > 0
          cc_coil.setDesignInletWaterTemperature(cc_ewt_si)
        end
        if cc_eat_si > 0
          cc_coil.setDesignInletAirTemperature(cc_eat_si)
        end
        if cc_lat_si > 0
          cc_coil.setDesignOutletAirTemperature(cc_lat_si)
        end
        if cc_humrat_in > 0
          cc.setDesignInletAirHumidityRatio(cc_humrat_in)
        end
        if cc_humrat_out > 0
          cc.setDesignOutletAirHumidityRatio(cc_humrat_out)
        end
        cc.setTypeOfAnalysis(cc_analysis)
        cc.	setHeatExchangerConfiguration(cc_config)

        # set htg coil fields
        #if hc_sched TODO
        if hc_ua > 0
          hc.setUFactorTimesAreaValue(hc_ua_si)
        end
        if hc_wtr_flow_max > 0
          hc.setMaximumWaterFlowRate(hc_wtr_flow_max_si)
        end
        hc.setPerformanceInputMethod(hc_perf)
        if hc_cap > 0
          hc.setRatedCapacity(hc_cap_si)
        end
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
        if hc_conv_ratio > 0
          hc.setRatedRatioForAirAndWaterConvection(hc_conv_ratio)
        end

        counter += 1

      else

        error = true

      end

    end #main

    if error == true
      runner.registerError('String not found.')
    end

    # final conditions
    runner.registerFinalCondition('Number of FCUs changed = #{counter}')

    return true

  end #end the run method

end #end the measure

#this allows the measure to be use by the application
SetFCUInputs.new.registerWithApplication

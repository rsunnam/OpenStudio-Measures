# start the measure
class SetWSHPInputs < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "Set WSHP Inputs"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    # argument for string
		string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", true)
		string.setDisplayName("Set inputs for equipment containing the string (case sensitive, enter *.* for all):")
    string.setDefaultValue("*.*")
		args << string
'
    # argument for autosize
    autosize = OpenStudio::Ruleset::OSArgument::makeBoolArgument("autosize", false)
    autosize.setDisplayName("Autosize all fields?")
    autosize.setDefaultValue(false)
    args << autosize
'
    # WSHP Inputs
'
ZoneHVAC:WaterToAirHeatPump,
    ,                        !- Name
    ,                        !- Availability Schedule Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Outdoor Air Mixer Object Type
    ,                        !- Outdoor Air Mixer Name
    ,                        !- Supply Air Flow Rate During Cooling Operation {m3/s}
    ,                        !- Supply Air Flow Rate During Heating Operation {m3/s}
    ,                        !- Supply Air Flow Rate When No Cooling or Heating is Needed {m3/s}
    ,                        !- Outdoor Air Flow Rate During Cooling Operation {m3/s}
    ,                        !- Outdoor Air Flow Rate During Heating Operation {m3/s}
    ,                        !- Outdoor Air Flow Rate When No Cooling or Heating is Needed {m3/s}
    ,                        !- Supply Air Fan Object Type
    ,                        !- Supply Air Fan Name
    ,                        !- Heating Coil Object Type
    ,                        !- Heating Coil Name
    ,                        !- Cooling Coil Object Type
    ,                        !- Cooling Coil Name
    2.5,                     !- Maximum Cycling Rate {cycles/hr}
    60.0,                    !- Heat Pump Time Constant {s}
    0.01,                    !- Fraction of On-Cycle Power Use
    60,                      !- Heat Pump Fan Delay Time {s}
    ,                        !- Supplemental Heating Coil Object Type
    ,                        !- Supplemental Heating Coil Name
    ,                        !- Maximum Supply Air Temperature from Supplemental Heater {C}
    21.0,                    !- Maximum Outdoor Dry-Bulb Temperature for Supplemental Heater Operation {C}
    ,                        !- Outdoor Dry-Bulb Temperature Sensor Node Name
    BlowThrough,             !- Fan Placement
    ,                        !- Supply Air Fan Operating Mode Schedule Name
    ,                        !- Availability Manager List Name
    Cycling;                 !- Heat Pump Coil Water Flow Mode

'
    wshp_flow_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_flow_clg', true)
    wshp_flow_clg.setDisplayName("WSHP: Supply Air Flow Rate During Cooling Operation {ft3/min}")
    wshp_flow_clg.setDefaultValue(-1)
    args << wshp_flow_clg

    wshp_flow_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_flow_htg', true)
    wshp_flow_htg.setDisplayName("WSHP: Supply Air Flow Rate During Heating Operation {ft3/min}")
    wshp_flow_htg.setDefaultValue(-1)
    args << wshp_flow_htg

    wshp_flow_no_clg_or_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_flow_no_clg_or_htg', true)
    wshp_flow_no_clg_or_htg.setDisplayName("WSHP: Supply Air Flow Rate When No Cooling or Heating is Needed {ft3/min}")
    wshp_flow_no_clg_or_htg.setDefaultValue(-1)
    args << wshp_flow_no_clg_or_htg

    wshp_oa_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_oa_clg', true)
    wshp_oa_clg.setDisplayName("WSHP: Outdoor Air Flow Rate During Cooling Operation {ft3/min}")
    wshp_oa_clg.setDefaultValue(-1)
    args << wshp_oa_clg

    wshp_oa_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_oa_htg', true)
    wshp_oa_htg.setDisplayName("WSHP: Outdoor Air Flow Rate During Heating Operation {ft3/min}")
    wshp_oa_htg.setDefaultValue(-1)
    args << wshp_oa_htg

    wshp_oa_no_clg_or_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('wshp_oa_no_clg_or_htg', true)
    wshp_oa_no_clg_or_htg.setDisplayName("WSHP: Outdoor Air Flow Rate When No Cooling or Heating is Needed {ft3/min}")
    wshp_oa_no_clg_or_htg.setDefaultValue(-1)
    args << wshp_oa_no_clg_or_htg

    # fan schedule TODO see PTAC measure

    # FanOnOff inputs
'
Fan:OnOff,
    ,                        !- Name
    ,                        !- Availability Schedule Name
    0.6,                     !- Fan Total Efficiency
    ,                        !- Pressure Rise {Pa}
    ,                        !- Maximum Flow Rate {m3/s}
    0.8,                     !- Motor Efficiency
    1.0,                     !- Motor In Airstream Fraction
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Fan Power Ratio Function of Speed Ratio Curve Name
    ,                        !- Fan Efficiency Ratio Function of Speed Ratio Curve Name
    General;                 !- End-Use Subcategory
'
    fan_eff_tot = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fan_eff_tot', true)
    fan_eff_tot.setDisplayName("Fan: Fan Total Efficiency")
    fan_eff_tot.setDefaultValue(-1)
    args << fan_eff_tot

    fan_rise = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fan_rise', true)
    fan_rise.setDisplayName("Fan: Pressure Rise {inH2O}")
    fan_rise.setDefaultValue(-1)
    args << fan_rise

    fan_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fan_flow', true)
    fan_flow.setDisplayName("Fan: Maximum Flow Rate {ft3/min}")
    fan_flow.setDefaultValue(-1)
    args << fan_flow

    fan_eff_mot = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('fan_eff_mot', true)
    fan_eff_mot.setDisplayName("Fan: Motor Efficiency")
    fan_eff_mot.setDefaultValue(-1)
    args << fan_eff_mot
'
Coil:Heating:WaterToAirHeatPump:EquationFit,
    ,                        !- Name
    ,                        !- Water Inlet Node Name
    ,                        !- Water Outlet Node Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Rated Air Flow Rate {m3/s}
    ,                        !- Rated Water Flow Rate {m3/s}
    ,                        !- Gross Rated Heating Capacity {W}
    ,                        !- Gross Rated Heating COP
    ,                        !- Heating Capacity Coefficient 1
    ,                        !- Heating Capacity Coefficient 2
    ,                        !- Heating Capacity Coefficient 3
    ,                        !- Heating Capacity Coefficient 4
    ,                        !- Heating Capacity Coefficient 5
    ,                        !- Heating Power Consumption Coefficient 1
    ,                        !- Heating Power Consumption Coefficient 2
    ,                        !- Heating Power Consumption Coefficient 3
    ,                        !- Heating Power Consumption Coefficient 4
    1;                       !- Heating Power Consumption Coefficient 5
'
    # Htg Coil inputs

    hc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_air_flow", false)
    hc_air_flow.setDisplayName("Htg Coil: Rated Air Flow Rate {ft3/min}")
    hc_air_flow.setDefaultValue(-1)
    args << hc_air_flow

    hc_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_wtr_flow", false)
    hc_wtr_flow.setDisplayName("Htg Coil: Rated Water Flow Rate {ft3/min}")
    hc_wtr_flow.setDefaultValue(-1)
    args << hc_wtr_flow

    hc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_cap", false)
    hc_cap.setDisplayName("Htg Coil: Gross Rated Heating Capacity {Btu/h}")
    hc_cap.setDefaultValue(-1)
    args << hc_cap

    hc_cop = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("hc_cop", false)
    hc_cop.setDisplayName("Htg Coil: Gross Rated Heating COP")
    hc_cop.setDefaultValue(-1)
    args << hc_cop
'
Coil:Cooling:WaterToAirHeatPump:EquationFit,
    ,                        !- Name
    ,                        !- Water Inlet Node Name
    ,                        !- Water Outlet Node Name
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Rated Air Flow Rate {m3/s}
    ,                        !- Rated Water Flow Rate {m3/s}
    ,                        !- Gross Rated Total Cooling Capacity {W}
    ,                        !- Gross Rated Sensible Cooling Capacity {W}
    ,                        !- Gross Rated Cooling COP
    ,                        !- Total Cooling Capacity Coefficient 1
    ,                        !- Total Cooling Capacity Coefficient 2
    ,                        !- Total Cooling Capacity Coefficient 3
    ,                        !- Total Cooling Capacity Coefficient 4
    ,                        !- Total Cooling Capacity Coefficient 5
    ,                        !- Sensible Cooling Capacity Coefficient 1
    ,                        !- Sensible Cooling Capacity Coefficient 2
    ,                        !- Sensible Cooling Capacity Coefficient 3
    ,                        !- Sensible Cooling Capacity Coefficient 4
    ,                        !- Sensible Cooling Capacity Coefficient 5
    ,                        !- Sensible Cooling Capacity Coefficient 6
    ,                        !- Cooling Power Consumption Coefficient 1
    ,                        !- Cooling Power Consumption Coefficient 2
    ,                        !- Cooling Power Consumption Coefficient 3
    ,                        !- Cooling Power Consumption Coefficient 4
    ,                        !- Cooling Power Consumption Coefficient 5
    0.0,                     !- Nominal Time for Condensate Removal to Begin {s}
    0.0;                     !- Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity {dimensionless}
'
    # Clg Coil inputs

    cc_air_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_air_flow", false)
    cc_air_flow.setDisplayName("Clg Coil: Rated Air Flow Rate {ft3/min}")
    cc_air_flow.setDefaultValue(-1)
    args << cc_air_flow

    cc_wtr_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_wtr_flow", false)
    cc_wtr_flow.setDisplayName("Clg Coil: Rated Water Flow Rate {ft3/min}")
    cc_wtr_flow.setDefaultValue(-1)
    args << cc_wtr_flow

    cc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_cap", false)
    cc_cap.setDisplayName("Clg Coil: Gross Rated Cooling Capacity {Btu/h}")
    cc_cap.setDefaultValue(-1)
    args << cc_cap

    cc_sen_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_sen_cap", false)
    cc_sen_cap.setDisplayName("Clg Coil: Gross Rated Sensible Cooling Capacity {Btu/h}")
    cc_sen_cap.setDefaultValue(-1)
    args << cc_sen_cap

    cc_cop = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_cop", false)
    cc_cop.setDisplayName("Clg Coil: Gross Rated Cooling COP")
    cc_cop.setDefaultValue(-1)
    args << cc_cop

    return args

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign user inputs to variables and convert to SI units for simulation
    string = runner.getStringArgumentValue("string", user_arguments)
    # wshp
    wshp_oa_clg = runner.getDoubleArgumentValue("wshp_oa_clg", user_arguments)
    wshp_oa_clg_si = OpenStudio.convert(wshp_oa_clg, "ft^3/min", "m^3/s").get
    wshp_oa_htg = runner.getDoubleArgumentValue("wshp_oa_htg", user_arguments)
    wshp_oa_htg_si = OpenStudio.convert(wshp_oa_htg, "ft^3/min", "m^3/s").get
    wshp_oa_no_clg_or_htg = runner.getDoubleArgumentValue("wshp_oa_no_clg_or_htg", user_arguments)
    wshp_oa_no_clg_or_htg_si = OpenStudio.convert(wshp_oa_no_clg_or_htg, "ft^3/min", "m^3/s").get
    # fan
    fan_eff_tot = runner.getDoubleArgumentValue("fan_eff_tot", user_arguments)
    fan_flow = runner.getDoubleArgumentValue("fan_flow", user_arguments)
    fan_flow_si = OpenStudio.convert(fan_flow, "ft^3/min", "m^3/s").get
    fan_rise = runner.getDoubleArgumentValue("fan_rise", user_arguments)
    fan_rise_si = OpenStudio.convert(fan_rise, "inH_{2}O", "Pa").get
    fan_eff_mot = runner.getDoubleArgumentValue("fan_eff_mot", user_arguments)
    # htg coil
    hc_air_flow = runner.getDoubleArgumentValue("hc_air_flow", user_arguments)
    hc_air_flow_si = OpenStudio.convert(hc_air_flow, "ft^3/min", "m^3/s").get
    hc_wtr_flow = runner.getDoubleArgumentValue("hc_wtr_flow", user_arguments)
    hc_wtr_flow_si = OpenStudio.convert(hc_wtr_flow, "ft^3/min", "m^3/s").get
    hc_cap = runner.getDoubleArgumentValue("hc_cap", user_arguments)
    hc_cap_si = OpenStudio.convert(hc_cap, "Btu/h", "W").get
    hc_cop = runner.getDoubleArgumentValue("hc_cop", user_arguments)
    # clg coil
    cc_air_flow = runner.getDoubleArgumentValue("cc_air_flow", user_arguments)
    cc_air_flow_si = OpenStudio.convert(cc_air_flow, "ft^3/min", "m^3/s").get
    cc_wtr_flow = runner.getDoubleArgumentValue("cc_wtr_flow", user_arguments)
    cc_wtr_flow_si = OpenStudio.convert(cc_wtr_flow, "ft^3/min", "m^3/s").get
    cc_cap = runner.getDoubleArgumentValue("cc_cap", user_arguments)
    cc_cap_si = OpenStudio.convert(cc_cap, "Btu/h", "W").get
    cc_sen_cap = runner.getDoubleArgumentValue("cc_sen_cap", user_arguments)
    cc_sen_cap_si = OpenStudio.convert(cc_sen_cap, "Btu/h", "W").get
    cc_cop = runner.getDoubleArgumentValue("cc_cop", user_arguments)

    # get model objects
    wshps = model.getZoneHVACWaterToAirHeatPumps
    fans = model.getFanOnOffs
    htg_coils = model.getCoilHeatingWaterToAirHeatPumpEquationFits
    clg_coils = model.getCoilCoolingWaterToAirHeatPumpEquationFits

    # report initial conditions
    runner.registerInitialCondition("Number of WSHPs in the model = #{wshps.size}")
    runner.registerInfo("String = #{string}")

    # initialize reporting variables
    n_wshps = 0
    error = false

    wshps.each do |wshp|

      if wshp.name.to_s.include? string or string == "*.*" # || doesn't work for 'or'

        runner.registerInfo("Setting fields for: #{wshp.name}")

        # get components
        fan = wshp.supplyAirFan.to_FanOnOff.get #TODO add other types in versions > 1.7.0
        htg_coil = wshp.heatingCoil.to_CoilHeatingWaterToAirHeatPumpEquationFit.get
        clg_coil = wshp.coolingCoil.to_CoilCoolingWaterToAirHeatPumpEquationFit.get

        # set WSHP fields
        if wshp_oa_clg > 0
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_oa_clg_si)
          wshp.setOutdoorAirFlowRateDuringCoolingOperation(optionalDouble)
        end
        if wshp_oa_htg > 0
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_oa_htg_si)
          wshp.setOutdoorAirFlowRateDuringHeatingOperation(optionalDouble)
        end
        if wshp_oa_no_clg_or_htg > 0
          optionalDouble = OpenStudio::OptionalDouble.new(wshp_oa_no_clg_or_htg_si)
          wshp.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(optionalDouble)
        end

        # set fan fields
        if fan_eff_tot > 0
          fan.setFanEfficiency(fan_eff_tot)
        end
        if fan_rise_si > 0
          fan.setPressureRise(fan_rise_si)
        end
        if fan_flow_si > 0
          fan.setMaximumFlowRate(fan_flow_si)
        end
        if fan_eff_mot > 0
          fan.setMotorEfficiency(fan_eff_mot)
        end

        # set htg coil fields
        if hc_air_flow > 0
          optionalDouble = OpenStudio::OptionalDouble.new(hc_air_flow_si)
          htg_coil.setRatedAirFlowRate(optionalDouble)
        end
        if hc_wtr_flow > 0
          optionalDouble = OpenStudio::OptionalDouble.new(hc_wtr_flow_si)
          htg_coil.setRatedWaterFlowRate(optionalDouble)
        end
        if hc_cap > 0
          optionalDoubleCap = OpenStudio::OptionalDouble.new(hc_cap_si)
          htg_coil.setRatedHeatingCapacity(optionalDoubleCap)
        end
        if hc_cop > 0
          #optionalDoubleCOP = OpenStudio::OptionalDouble.new(hc_cop)
          htg_coil.setRatedHeatingCoefficientofPerformance(hc_cop) #not setRatedCOP
        end

        # set clg coil fields
        if cc_air_flow > 0
          #optionalDouble = OpenStudio::OptionalDouble.new(cc_air_flow)
          clg_coil.setRatedAirFlowRate(cc_air_flow_si)
        end
        if cc_wtr_flow > 0
          #optionalDouble = OpenStudio::OptionalDouble.new(cc_wtr_flow)
          clg_coil.setRatedWaterFlowRate(cc_wtr_flow_si)
        end
        if cc_cap > 0
          #optionalDoubleCap = OpenStudio::OptionalDouble.new(cc_cap)
          clg_coil.setRatedTotalCoolingCapacity(cc_cap_si)
        end
        if cc_sen_cap > 0
          #optionalDoubleCap = OpenStudio::OptionalDouble.new(cc_sen_cap)
          clg_coil.setRatedSensibleCoolingCapacity(cc_sen_cap_si)
        end
        if cc_cop > 0
          #optionalDoubleCOP = OpenStudio::OptionalDouble.new(hc_cop)
          clg_coil.setRatedCoolingCoefficientofPerformance(hc_cop)
        end

        n_wshps += 1

      else

        error = true

      end

    end

    # report error
    if error == true
      runner.registerError("String not found.")
    end

    # report final conditions
    runner.registerFinalCondition("Number of WSHPs changed = #{n_wshps}")

    return true

  end

end

#this allows the measure to be use by the application
SetWSHPInputs.new.registerWithApplication

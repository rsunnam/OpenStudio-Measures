# start the measure
class SetPTACInputs < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see, this method may be deprecated as
  #the display name in PAT comes from the name field in measure.xml
  def name
    return "Set PTAC Inputs"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

		# argument for string
		string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", true)
		string.setDisplayName("Set inputs for equipment containing the string (case sensitive, enter *.* for all):")
    string.setDefaultValue("*.*")
		args << string

    # PTAC inputs
'
ZoneHVAC:PackagedTerminalAirConditioner,
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
  DrawThrough,             !- Fan Placement
  ,                        !- Supply Air Fan Operating Mode Schedule Name
  ,                        !- Availability Manager List Name
  1;                       !- Design Specification ZoneHVAC Sizing Object Name
'
    ptac_flow_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('ptac_flow_clg', true)
    ptac_flow_clg.setDisplayName("PTAC: Supply Air Flow Rate During Cooling Operation {ft3/min}")
    ptac_flow_clg.setDefaultValue(-1)
    args << ptac_flow_clg

    ptac_flow_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('ptac_flow_htg', true)
    ptac_flow_htg.setDisplayName("PTAC: Supply Air Flow Rate During Heating Operation {ft3/min}")
    ptac_flow_htg.setDefaultValue(-1)
    args << ptac_flow_htg

    ptac_flow_no_clg_or_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument('ptac_flow_no_clg_or_htg', true)
    ptac_flow_no_clg_or_htg.setDisplayName("PTAC: Supply Air Flow Rate When No Cooling or Heating is Needed {ft3/min}")
    ptac_flow_no_clg_or_htg.setDefaultValue(-1)
    args << ptac_flow_no_clg_or_htg

    ptac_oa_clg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_oa_clg",false)
    ptac_oa_clg.setDisplayName("PTAC: Outdoor Air Flow Rate During Cooling Operation {ft3/min}")
    ptac_oa_clg.setDefaultValue(-1)
    args << ptac_oa_clg

    ptac_oa_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_oa_htg",false)
    ptac_oa_htg.setDisplayName("PTAC: Outdoor Air Flow Rate During Heating Operation {ft3/min}")
    ptac_oa_htg.setDefaultValue(-1)
    args << ptac_oa_htg

    ptac_oa_no_clg_or_htg = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("ptac_oa_no_clg_or_htg",false)
    ptac_oa_no_clg_or_htg.setDisplayName("PTAC: Outdoor Air Flow Rate When No Cooling or Heating is Needed {ft3/min}")
    ptac_oa_no_clg_or_htg.setDefaultValue(-1)
    args << ptac_oa_no_clg_or_htg
'
    #populate choice argument for schedules in the model
    sch_handles = OpenStudio::StringVector.new
    sch_display_names = OpenStudio::StringVector.new

    #putting schedule names into hash
    sch_hash = {}
    model.getSchedules.each do |sch|
      sch_hash[sch.name.to_s] = sch
    end

    #looping through sorted hash of schedules
    sch_hash.sort.map do |sch_name, sch|
      if not sch.scheduleTypeLimits.empty?
        unitType = sch.scheduleTypeLimits.get.unitType
        #puts "#{sch.name}, #{unitType}"
        if unitType == "Availability"
          sch_handles << sch.handle.to_s
          sch_display_names << sch_name
        end
      end
    end

		#argument for schedules
    sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("sched", sch_handles, sch_display_names, false)
    sched.setDisplayName("PTAC: Supply Air Fan Operating Mode Schedule Name")
    args << sched
'
    # Fan Inputs TODO add additional types when available: OnOff
'
Fan:ConstantVolume,
    ,                        !- Name
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

    # Htg Coil Inputs TODO add additional when available after 1.6.0

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

    # Clg Coil Inputs
'
Coil:Cooling:DX:SingleSpeed,
    ,                        !- Name
    ,                        !- Availability Schedule Name
    ,                        !- Gross Rated Total Cooling Capacity {W}
    ,                        !- Gross Rated Sensible Heat Ratio
    3,                       !- Gross Rated Cooling COP {W/W}
    ,                        !- Rated Air Flow Rate {m3/s}
    773.3,                   !- Rated Evaporator Fan Power Per Volume Flow Rate {W/(m3/s)}
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Total Cooling Capacity Function of Temperature Curve Name
    ,                        !- Total Cooling Capacity Function of Flow Fraction Curve Name
    ,                        !- Energy Input Ratio Function of Temperature Curve Name
    ,                        !- Energy Input Ratio Function of Flow Fraction Curve Name
    ,                        !- Part Load Fraction Correlation Curve Name
    ,                        !- Nominal Time for Condensate Removal to Begin {s}
    ,                        !- Ratio of Initial Moisture Evaporation Rate and Steady State Latent Capacity {dimensionless}
    ,                        !- Maximum Cycling Rate {cycles/hr}
    ,                        !- Latent Capacity Time Constant {s}
    ,                        !- Condenser Air Inlet Node Name
    AirCooled,               !- Condenser Type
    0.9,                     !- Evaporative Condenser Effectiveness {dimensionless}
    ,                        !- Evaporative Condenser Air Flow Rate {m3/s}
    ,                        !- Evaporative Condenser Pump Rated Power Consumption {W}
    ,                        !- Crankcase Heater Capacity {W}
    10,                      !- Maximum Outdoor Dry-Bulb Temperature for Crankcase Heater Operation {C}
    ,                        !- Supply Water Storage Tank Name
    ,                        !- Condensate Collection Water Storage Tank Name
    ,                        !- Basin Heater Capacity {W/K}
    2,                       !- Basin Heater Setpoint Temperature {C}
    ,                        !- Basin Heater Operating Schedule Name
    ,                        !- Sensible Heat Ratio Function of Temperature Curve Name
    1;                       !- Sensible Heat Ratio Function of Flow Fraction Curve Name
'
    cc_cap = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_cap", false)
    cc_cap.setDisplayName("Clg Coil: Gross Rated Total Cooling Capacity {Btu/h}")
    cc_cap.setDefaultValue(-1)
    args << cc_cap

    cc_shr = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_shr", false)
    cc_shr.setDisplayName("Clg Coil: Gross Rated Sensible Heat Ratio")
    cc_shr.setDefaultValue(-1)
    args << cc_shr

    cc_cop = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_cop", false)
    cc_cop.setDisplayName("Clg Coil: Gross Rated Cooling COP {Btuh/Btuh}")
    cc_cop.setDefaultValue(-1)
    args << cc_cop

    cc_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("cc_flow", false)
    cc_flow.setDisplayName("Clg Coil: Rated Air Flow Rate {ft3/min}")
    cc_flow.setDefaultValue(-1)
    args << cc_flow

    return args

  end

  #define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    #use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign user inputs to variables and convert to SI units for simulation
    string = runner.getStringArgumentValue("string", user_arguments)
    # ptac
    ptac_oa_clg = runner.getDoubleArgumentValue("ptac_oa_clg", user_arguments)
    ptac_oa_clg_si = OpenStudio.convert(ptac_oa_clg, "ft^3/min", "m^3/s").get
    ptac_oa_htg = runner.getDoubleArgumentValue("ptac_oa_htg", user_arguments)
    ptac_oa_htg_si = OpenStudio.convert(ptac_oa_htg, "ft^3/min", "m^3/s").get
    ptac_oa_no_clg_or_htg = runner.getDoubleArgumentValue("ptac_oa_no_clg_or_htg", user_arguments)
    ptac_oa_no_clg_or_htg_si = OpenStudio.convert(ptac_oa_no_clg_or_htg, "ft^3/min", "m^3/s").get
'    if sched.is_initialized
      sched = runner.getOptionalWorkspaceObjectChoiceValue("sched", user_arguments, model) #model is passed in because of argument type
      sched = sched.get.to_Schedule.get
    end
'    # fan
    fan_eff_tot = runner.getDoubleArgumentValue("fan_eff_tot", user_arguments)
    fan_flow = runner.getDoubleArgumentValue("fan_flow", user_arguments)
    fan_flow_si = OpenStudio.convert(fan_flow, "ft^3/min", "m^3/s").get
    fan_rise = runner.getDoubleArgumentValue("fan_rise", user_arguments)
    fan_rise_si = OpenStudio.convert(fan_rise, "inH_{2}O", "Pa").get
    fan_eff_mot = runner.getDoubleArgumentValue("fan_eff_mot", user_arguments)
    # htg coil
    hc_ewt = runner.getDoubleArgumentValue("hc_ewt", user_arguments)
    hc_ewt_si = OpenStudio.convert(hc_ewt, "F", "C").get
    hc_eat = runner.getDoubleArgumentValue("hc_eat", user_arguments)
    hc_eat_si = OpenStudio.convert(hc_eat, "F", "C").get
    hc_lwt = runner.getDoubleArgumentValue("hc_lwt", user_arguments)
    hc_lwt_si = OpenStudio.convert(hc_lwt, "F", "C").get
    hc_lat = runner.getDoubleArgumentValue("hc_lat", user_arguments)
    hc_lat_si = OpenStudio.convert(hc_lat, "F", "C").get
    # clg coil
    cc_cap = runner.getDoubleArgumentValue("cc_cap", user_arguments)
    cc_cap_si = OpenStudio.convert(cc_cap, "Btu/h", "W").get
    cc_shr = runner.getDoubleArgumentValue("cc_shr", user_arguments)
    cc_cop = runner.getDoubleArgumentValue("cc_cop", user_arguments)
    cc_flow = runner.getDoubleArgumentValue("cc_flow", user_arguments)
    cc_flow_si = OpenStudio.convert(cc_flow, "ft^3/min", "m^3/s").get

    # get model objects
    ptacs = model.getZoneHVACPackagedTerminalAirConditioners
    fans = model.getFanConstantVolumes #as of version 1.5.0 PTACs are limited to CAV fans which are automatically created
    htg_coils = model.getCoilHeatingWaters
    clg_coils = model.getCoilCoolingDXSingleSpeeds

    # report initial conditions
    runner.registerInitialCondition("Number of PTACs in the model = #{ptacs.size}")
    runner.registerInfo("String = #{string}")
#    runner.registerInfo("Schedule = #{sched}")

    # initialize reporting variables
    n_ptacs = 0
    error = false

    # MAIN BLOCK

    ptacs.each do |ptac|

      if ptac.name.to_s.include? string or string == "*.*" #couldn't use && here, ## ptac.name.to_s.include? "Hilton" and

        runner.registerInfo("Setting fields for: #{ptac.name}")

        # get components
        fan = ptac.supplyAirFan.to_FanConstantVolume.get
        htg_coil = ptac.heatingCoil.to_CoilHeatingWater.get
        clg_coil = ptac.coolingCoil.to_CoilCoolingDXSingleSpeed.get

        # set PTAC fields
        if ptac_oa_clg > 0
          ptac.setOutdoorAirFlowRateDuringCoolingOperation(ptac_oa_clg_si)
        end
        if ptac_oa_htg > 0
          ptac.setOutdoorAirFlowRateDuringHeatingOperation(ptac_oa_htg_si)
        end
        if ptac_oa_no_clg_or_htg > 0
          ptac.setOutdoorAirFlowRateWhenNoCoolingorHeatingisNeeded(ptac_oa_no_clg_or_htg_si)
        end
'        if sched != "#"
          ptac.setSupplyAirFanOperatingModeSchedule(sched)
        end
'
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

        # set clg coil fields
        if cc_cap > 0
          clg_coil.setRatedTotalCoolingCapacity(cc_cap_si)
        end
        if cc_shr > 0
          clg_coil.setRatedSensibleHeatRatio(cc_shr)
        end
        if cc_cop > 0
          optionalDoubleCOP = OpenStudio::OptionalDouble.new(cc_cop)
          clg_coil.setRatedCOP(optionalDoubleCOP)
        end
        if cc_flow > 0
          clg_coil.setRatedAirFlowRate(cc_flow_si)
        end

        n_ptacs += 1

      else

        error = true

      end

    end

    # report error
    if error == true
      runner.registerError("String not found.")
    end

    # report final conditions
    runner.registerFinalCondition("Number of PTACs changed = #{n_ptacs}")
    return true

  end

end

#this allows the measure to be use by the application
SetPTACInputs.new.registerWithApplication

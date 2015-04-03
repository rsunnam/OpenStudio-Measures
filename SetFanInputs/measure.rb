# start the measure
class SetFanInputs < OpenStudio::Ruleset::ModelUserScript

  # define the name that the user will see
  def name
    return "Set Fan Inputs"
  end

  # define the arguments that the user will input open
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    # NOTE versions
    # OS version = 1.7.0
    # EP version = 8.2

    # argument for string
		string = OpenStudio::Ruleset::OSArgument::makeStringArgument("string", true)
		string.setDisplayName("Set inputs for equipment containing the string (case sensitive, enter *.* for all):")
    string.setDefaultValue("*.*")
		args << string

    fan_choices = OpenStudio::StringVector.new
    fan_choices << "FanConstantVolume"
    fan_choices << "FanOnOff"
    fan_choices << "FanVariableVolume"
    fan_choices << "FanZoneExhaust"
    fan_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("fan_type", fan_choices, true)
    fan_type.setDisplayName("Fan Type")
    fan_type.setDefaultValue("FanConstantVolume")
    args << fan_type

    # common fan arguments
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
    fan_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("fan_sched", sch_handles, sch_display_names, false)
    fan_sched.setDisplayName("Availability Schedule Name")
    args << fan_sched

    fan_eff_tot = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_eff_tot", true)
    fan_eff_tot.setDisplayName("Fan Total Efficiency")
    fan_eff_tot.setDefaultValue(-1)
    args << fan_eff_tot

    fan_rise = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_rise", true)
    fan_rise.setDisplayName("Pressure Rise {inH2O}")
    fan_rise.setDefaultValue(-1)
    args << fan_rise

    fan_flow = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_flow", true)
    fan_flow.setDisplayName("Maximum Flow Rate {ft3/min}")
    fan_flow.setDefaultValue(-1)
    args << fan_flow

    fan_eff_mot = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_eff_mot", true)
    fan_eff_mot.setDisplayName("Motor Efficiency")
    fan_eff_mot.setDefaultValue(-1)
    args << fan_eff_mot

    fan_mot_heat = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("fan_mot_heat", true)
    fan_mot_heat.setDisplayName("Motor In Airstream Fraction")
    fan_mot_heat.setDefaultValue(-1)
    args << fan_mot_heat
'
Fan:OnOff,
    ,                        !- Name
    ,                        !- Availability Schedule Name
    0.6,                     !- Fan Total Efficiency
    ,                        !- Pressure Rise {Pa}
    ,                        !- Maximum Flow Rate {m3/s}
    0.8,                     !- Motor Efficiency
    1,                       !- Motor In Airstream Fraction
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    ,                        !- Fan Power Ratio Function of Speed Ratio Curve Name
    ,                        !- Fan Efficiency Ratio Function of Speed Ratio Curve Name
    General;                 !- End-Use Subcategory
'
    # FanOnOff
    # as of 1.7.0 user cannot edit curves
'
Fan:VariableVolume,
    ,                        !- Name
    ,                        !- Availability Schedule Name
    0.7,                     !- Fan Total Efficiency
    ,                        !- Pressure Rise {Pa}
    ,                        !- Maximum Flow Rate {m3/s}
    Fraction,                !- Fan Power Minimum Flow Rate Input Method
    0.25,                    !- Fan Power Minimum Flow Fraction
    ,                        !- Fan Power Minimum Air Flow Rate {m3/s}
    0.9,                     !- Motor Efficiency
    1,                       !- Motor In Airstream Fraction
    ,                        !- Fan Power Coefficient 1
    ,                        !- Fan Power Coefficient 2
    ,                        !- Fan Power Coefficient 3
    ,                        !- Fan Power Coefficient 4
    ,                        !- Fan Power Coefficient 5
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    General;                 !- End-Use Subcategory
'
    # FanVariableVolume arguments

    vav_choices = OpenStudio::StringVector.new
    vav_choices << "FixedFlowRate"
    vav_choices << "Fraction"
    vav_min_flow_method = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("vav_min_flow_method", vav_choices, true)
    vav_min_flow_method.setDisplayName("VAV: Fan Power Minimum Flow Rate Input Method")
    vav_min_flow_method.setDefaultValue("Fraction")
    args << vav_min_flow_method

    vav_min_flow_frac = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_min_flow_frac", true)
    vav_min_flow_frac.setDisplayName("VAV: Fan Power Minimum Flow Fraction")
    vav_min_flow_frac.setDefaultValue(-1)
    args << vav_min_flow_frac

    vav_min_flow_rate = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_min_flow_rate", true)
    vav_min_flow_rate.setDisplayName("VAV: Fan Power Minimum Air Flow Rate {ft3/min}")
    vav_min_flow_rate.setDefaultValue(-1)
    args << vav_min_flow_rate

    vav_coeffs = OpenStudio::Ruleset::OSArgument::makeBoolArgument("vav_coeffs", true)
    vav_coeffs.setDisplayName("Change VAV fan power coefficients?")
    vav_coeffs.setDefaultValue(false)
    args << vav_coeffs

    vav_c1 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c1", true)
    vav_c1.setDisplayName("VAV: Fan Power Coefficient 1")
    vav_c1.setDefaultValue(-1)
    args << vav_c1

    vav_c2 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c2", true)
    vav_c2.setDisplayName("VAV: Fan Power Coefficient 2")
    vav_c2.setDefaultValue(-1)
    args << vav_c2

    vav_c3 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c3", true)
    vav_c3.setDisplayName("VAV: Fan Power Coefficient 3")
    vav_c3.setDefaultValue(-1)
    args << vav_c3

    vav_c4 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c4", true)
    vav_c4.setDisplayName("VAV: Fan Power Coefficient 4")
    vav_c4.setDefaultValue(-1)
    args << vav_c4

    vav_c5 = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("vav_c5", true)
    vav_c5.setDisplayName("VAV: Fan Power Coefficient 5")
    vav_c5.setDefaultValue(-1)
    args << vav_c5
'
Fan:ZoneExhaust,
    ,                        !- Name
    ,                        !- Availability Schedule Name
    0.6,                     !- Fan Total Efficiency
    ,                        !- Pressure Rise {Pa}
    ,                        !- Maximum Flow Rate {m3/s}
    ,                        !- Air Inlet Node Name
    ,                        !- Air Outlet Node Name
    General,                 !- End-Use Subcategory
    ,                        !- Flow Fraction Schedule Name
    Coupled,                 !- System Availability Manager Coupling Mode
    ,                        !- Minimum Zone Temperature Limit Schedule Name
    0;                       !- Balanced Exhaust Fraction Schedule Name
'
    # FanZoneExhaust arguments

    ef_end_use = OpenStudio::Ruleset::OSArgument::makeStringArgument("ef_end_use", true)
    ef_end_use.setDisplayName("EF: End-Use Subcategory")
    ef_end_use.setDefaultValue("General")
    args << ef_end_use

    ef_flow_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ef_flow_sched", sch_handles, sch_display_names, false)
    ef_flow_sched.setDisplayName("EF: Flow Fraction Schedule Name")
    args << ef_flow_sched

    ef_choices = OpenStudio::StringVector.new
    ef_choices << "Coupled"
    ef_choices << "Decoupled"
    ef_mode = OpenStudio::Ruleset::OSArgument::makeChoiceArgument('ef_mode', ef_choices, true)
    ef_mode.setDisplayName("EF: System Availability Manager Coupling Mode")
    ef_mode.setDefaultValue("Coupled")
    args << ef_mode

    ef_temp_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ef_temp_sched", sch_handles, sch_display_names, false)
    ef_temp_sched.setDisplayName("EF: Minimum Zone Temperature Limit Schedule Name")
    args << ef_temp_sched

    ef_balance_sched = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("ef_balance_sched", sch_handles, sch_display_names, false)
    ef_balance_sched.setDisplayName("EF: Balanced Exhaust Fraction Schedule Name")
    args << ef_balance_sched

    return args

  end #def arguments

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # get user arguments, convert to SI units for simulation
    string = runner.getStringArgumentValue("string", user_arguments)
    fan_type = runner.getStringArgumentValue("fan_type", user_arguments)
    #fan_sched = runner.getOptionalWorkspaceObjectChoiceValue("fan_sched", user_arguments, model)
    #fan_sched = fan_sched.get.to_Schedule.get
    fan_eff_tot = runner.getDoubleArgumentValue("fan_eff_tot", user_arguments)
    fan_rise = runner.getDoubleArgumentValue("fan_rise", user_arguments)
    fan_rise_si = OpenStudio.convert(fan_rise, "inH_{2}O", "Pa").get
    fan_flow = runner.getDoubleArgumentValue("fan_flow", user_arguments)
    fan_flow_si = OpenStudio.convert(fan_flow, "ft^3/min", "m^3/s").get
    fan_eff_mot = runner.getDoubleArgumentValue("fan_eff_mot", user_arguments)
    fan_mot_heat = runner.getDoubleArgumentValue("fan_mot_heat", user_arguments)
    vav_coeffs = runner.getBoolArgumentValue("vav_coeffs", user_arguments)

    if fan_type == "FanVariableVolume"

      vav_min_flow_method = runner.getStringArgumentValue("vav_min_flow_method", user_arguments)
      vav_min_flow_frac = runner.getDoubleArgumentValue("vav_min_flow_frac", user_arguments)
      vav_min_flow_rate = runner.getDoubleArgumentValue("vav_min_flow_rate", user_arguments)
      vav_min_flow_rate_si = OpenStudio.convert(vav_min_flow_rate, "ft^3/min", "m^3/s").get

      if vav_coeffs == true
        vav_c1 = runner.getDoubleArgumentValue("vav_c1", user_arguments)
        vav_c2 = runner.getDoubleArgumentValue("vav_c2", user_arguments)
        vav_c3 = runner.getDoubleArgumentValue("vav_c3", user_arguments)
        vav_c4 = runner.getDoubleArgumentValue("vav_c4", user_arguments)
        vav_c5 = runner.getDoubleArgumentValue("vav_c5", user_arguments)
      end

    end

    if fan_type == "FanZoneExhaust"

      ef_end_use = runner.getStringArgumentValue("ef_end_use", user_arguments)
#      ef_flow_sched = runner.getOptionalWorkspaceObjectChoiceValue("ef_flow_sched", user_arguments, model)
      ef_mode = runner.getStringArgumentValue("ef_mode", user_arguments)
#      ef_temp_sched = runner.getOptionalWorkspaceObjectChoiceValue("ef_temp_sched", user_arguments, model)
#      ef_balance_sched = runner.getOptionalWorkspaceObjectChoiceValue("ef_balance_sched", user_arguments, model)

    end

    # get model objects, report initial conditions
    if fan_type == "FanConstantVolume"
      fans = model.getFanConstantVolumes
      runner.registerInitialCondition("Number of CAV fans in model = #{fans.size}")
    elsif fan_type == "FanOnOff"
      fans = model.getFanOnOffs
      runner.registerInitialCondition("Number of OnOff fans in model = #{fans.size}")
    elsif fan_type == "FanVariableVolume"
      fans = model.getFanVariableVolumes
      runner.registerInitialCondition("Number of VAV fans in model = #{fans.size}")
    elsif fan_type == "FanZoneExhaust"
      fans = model.getFanZoneExhausts
      runner.registerInitialCondition("Number of exhaust fans in model = #{fans.size}")
    else
      runner.registerError("Fan type not found")
    end

    # initialize variables
    counter = 0

    # MAIN

    fans.each do |fan|

      if fan.name.to_s.include? string or string == "*.*"

        # set common inputs
  '      if fan_sched.size > 1
          fan.setAvailabilitySchedule(fan_sched)
        end
  '
        if fan_eff_tot > 0
          fan.setFanEfficiency(fan_eff_tot)
        end
        if fan_rise > 0
          fan.setPressureRise(fan_rise_si)
        end
        if fan_flow > 0
          fan.setMaximumFlowRate(fan_flow_si)
        end
        if fan_eff_mot > 0
          fan.setMotorEfficiency(fan_eff_mot) unless fan_type == "FanZoneExhaust"
        end
        if fan_mot_heat > 0
          fan.setMotorInAirstreamFraction(fan_mot_heat) unless fan_type == "FanZoneExhaust"
        end

        # set on off inputs
        if fan_type == "FanOnOff"
          #TODO future curves
        end

        # set vav inputs
        if fan_type == "FanVariableVolume"

          fan.setFanPowerMinimumFlowRateInputMethod(vav_min_flow_method)
          if vav_min_flow_frac > 0
            fan.setFanPowerMinimumFlowFraction(vav_min_flow_frac)
          end
          if vav_min_flow_rate > 0
            fan.setFanPowerMinimumAirFlowRate(vav_min_flow_rate_si)
          end
          if vav_coeffs == true
            fan.setFanPowerCoefficient1(vav_c1)
        		fan.setFanPowerCoefficient2(vav_c2)
        		fan.setFanPowerCoefficient3(vav_c3)
        		fan.setFanPowerCoefficient4(vav_c4)
        		fan.setFanPowerCoefficient5(vav_c5)
          end

        end

        # set exhaust fan inputs
        if fan_type == "FanZoneExhaust"
          fan.setEndUseSubcategory(ef_end_use)
          #TODO schedules
          fan.setSystemAvailabilityManagerCouplingMode(ef_mode)
        end

        counter += 1

      end

    end #main

    # report final conditions
    runner.registerFinalCondition("Number of fans changed = #{counter}")

    return true

  end #def

end #class

#this allows the measure to be used by the application
SetFanInputs.new.registerWithApplication

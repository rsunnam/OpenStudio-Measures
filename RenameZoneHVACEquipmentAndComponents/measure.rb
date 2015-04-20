# start the measure
class RenameZoneHVACEquipmentAndComponents < OpenStudio::Ruleset::ModelUserScript

  #define the name that a user will see
  def name
    return "Rename Zone HVAC Equipment And Components"
  end

  #define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    # argument for zone hvac equipment TODO
'
ZoneHVAC:AirDistributionUnit
ZoneHVAC:Baseboard:Convective:Electric
ZoneHVAC:Baseboard:Convective:Water
ZoneHVAC:Baseboard:RadiantConvective:Electric
ZoneHVAC:Baseboard:RadiantConvective:Steam
ZoneHVAC:Baseboard:RadiantConvective:Water
ZoneHVAC:Dehumidifier:DX
ZoneHVAC:EnergyRecoveryVentilator
ZoneHVAC:EnergyRecoveryVentilator:Controller
ZoneHVAC:EquipmentConnections
ZoneHVAC:EquipmentList
ZoneHVAC:ForcedAir:UserDefined
#ZoneHVAC:FourPipeFanCoil
ZoneHVAC:HighTemperatureRadiant
ZoneHVAC:IdealLoadsAirSystem
ZoneHVAC:LowTemperatureRadiant:ConstantFlow
ZoneHVAC:LowTemperatureRadiant:Electric
ZoneHVAC:LowTemperatureRadiant:SurfaceGroup
ZoneHVAC:LowTemperatureRadiant:VariableFlow
ZoneHVAC:OutdoorAirUnit
ZoneHVAC:OutdoorAirUnit:EquipmentList
#ZoneHVAC:PackagedTerminalAirConditioner
ZoneHVAC:PackagedTerminalHeatPump
ZoneHVAC:RefrigerationChillerSet
ZoneHVAC:TerminalUnit:VariableRefrigerantFlow
#ZoneHVAC:UnitHeater
ZoneHVAC:UnitVentilator
ZoneHVAC:VentilatedSlab
ZoneHVAC:VentilatedSlab:SlabGroup
#ZoneHVAC:WaterToAirHeatPump
ZoneHVAC:WindowAirConditioner
'
    eqpt_choices = OpenStudio::StringVector.new
    #eqpt_choices << "ZoneHVAC:FourPipeFanCoil"
    #eqpt_choices << "ZoneHVAC:PackagedTerminalAirConditioner"
    eqpt_choices << "ZoneHVAC:WaterToAirHeatPump"
    eqpt_type = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("eqpt_type", eqpt_choices, true)
    eqpt_type.setDisplayName("Zone HVAC Equipment Type")
    args << eqpt_type

    # argument for rename zone hvac equipment
    rename_hvac_eqpt = OpenStudio::Ruleset::OSArgument::makeBoolArgument("rename_hvac_eqpt", false)
    rename_hvac_eqpt.setDisplayName("Rename zone HVAC equipment?")
    rename_hvac_eqpt.setDefaultValue(false)
    args << rename_hvac_eqpt

    # argument for rename zone hvac components
    rename_hvac_comp = OpenStudio::Ruleset::OSArgument::makeBoolArgument("rename_hvac_comp", false)
    rename_hvac_comp.setDisplayName("Rename zone HVAC equipment components?")
    rename_hvac_comp.setDefaultValue(false)
    args << rename_hvac_comp

    return args

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign user inputs to variables
    eqpt_type = runner.getStringArgumentValue("eqpt_type", user_arguments)
    rename_hvac_eqpt = runner.getBoolArgumentValue("rename_hvac_eqpt", user_arguments)
    rename_hvac_comp = runner.getBoolArgumentValue("rename_hvac_comp", user_arguments)

    # initialize variables


    # get model objects
    lists = model.getZoneHVACEquipmentLists
    zones = model.getThermalZones

    fcus = model.getZoneHVACFourPipeFanCoils
    ptacs = model.getZoneHVACPackagedTerminalAirConditioners
    pthps = model.getZoneHVACPackagedTerminalHeatPumps
    uhs = model.getZoneHVACUnitHeaters
    wshps = model.getZoneHVACWaterToAirHeatPumps

    # report initial condition


    # rename zone equipment and components
    zones.each do |z|

      zone_eqpt = z.equipment #vector

      zone_eqpt.each do |eqpt|

        # WSHPs
        if eqpt.to_ZoneHVACWaterToAirHeatPump.is_initialized
          # get equipment and components
          wshp = eqpt.to_ZoneHVACWaterToAirHeatPump.get
          fan = wshp.supplyAirFan.to_FanOnOff.get
          htg_coil = wshp.heatingCoil.to_CoilHeatingWaterToAirHeatPumpEquationFit.get
          clg_coil = wshp.coolingCoil.to_CoilCoolingWaterToAirHeatPumpEquationFit.get
          # rename equipment
          if rename_hvac_eqpt == true
            wshp.setName("#{z.name} WSHP")
            runner.registerInfo("renaming equipment")
          end
          #rename components
          if rename_hvac_comp == true
            runner.registerInfo("renaming components")
            fan.setName("#{wshp.name} Fan")
            htg_coil.setName("#{wshp.name} Htg Coil")
            clg_coil.setName("#{wshp.name} Clg Coil")
            runner.registerInfo("renaming components")
          end
        end

      end

    end

    # report final condition


    return true

  end #run

end #measure

#this allows the measure to be use by the application
RenameZoneHVACEquipmentAndComponents.new.registerWithApplication

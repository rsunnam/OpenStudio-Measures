# start the measure
class RenameSpacesBasedOnThermalZoneNames < OpenStudio::Ruleset::ModelUserScript

  # define the name that a user will see, this method may be deprecated as
  #   the display name in PAT comes from the name field in measure.xml
  def name
    return "Rename Spaces Based On Thermal Zone Names"
  end

  # define the arguments that the user will input
  def arguments(model)

    args = OpenStudio::Ruleset::OSArgumentVector.new

    # argument for renaming spaces with common parent zone
    rename = OpenStudio::Ruleset::OSArgument::makeBoolArgument("rename", true)
    rename.setDisplayName("Rename spaces with common thermal zone?")
    rename.setDefaultValue(false)
    args << rename

    return args

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign the user inputs to variables
    rename = runner.getBoolArgumentValue("rename", user_arguments)

    # report initial condition of model
    runner.registerInitialCondition("Number of Spaces in Model: #{model.getSpaces.size}")

    # main code block

    zones = model.getThermalZones
    cnt_spaces = 0

    zones.each do |z|

      spaces = z.spaces

      if spaces.size == 1 || rename == true
        spaces.each do |s|
          s.setName(z.name.to_s)
          cnt_spaces += 1
        end
      elsif spaces.size > 1 && rename == false
        runner.registerInfo("Thermal zone has multiple spaces: #{z.name}")
      else
        runner.registerInfo("Thermal zone does not have any spaces: #{z.name}")
      end

    end

    # report final condition of model
    runner.registerFinalCondition("Number of Spaces Renamed: #{cnt_spaces}")

    return true

  end

end

# register the measure to be used by the application
RenameSpacesBasedOnThermalZoneNames.new.registerWithApplication

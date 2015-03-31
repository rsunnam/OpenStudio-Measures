# start the measure
class AddRemoveOrReplaceWindowsByFacade < OpenStudio::Ruleset::ModelUserScrip

  # define the name that a user will see
  def name
    return "Add Remove Or Replace Windows By Facade"
  end

  # define the arguments that the user will enter
  def arguments(model)

    # create argument vector
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # argument for measure function
    function_choices = OpenStudio::StringVector.new
    function_choices << "Add"
    function_choices << "Remove"
    function_choices << "Replace"
    function = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("function", function_choices, true)
    function.setDisplayName("Choose Measure Function")
    function.setDefaultValue("Add")
    args << function

    # argument for facade
    facade_choices = OpenStudio::StringVector.new
    facade_choices << "North"
    facade_choices << "East"
    facade_choices << "South"
    facade_choices << "West"
    facade = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("facade", facade_choices, true)
    facade.setDisplayName("Cardinal Direction.")
    facade.setDefaultValue("South")
    args << facade

    # argument for wwr
    wwr = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("wwr", true)
    wwr.setDisplayName("Window to Wall Ratio (fraction)")
    wwr.setDefaultValue(0.4)
    args << wwr

    # argument for offset
    offset = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("offset", true)
    offset.setDisplayName("Height Offset from Floor (in)")
    offset.setDefaultValue(30.0)
    args << offset

    # return argument vector
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
    function = runner.getStringArgumentValue("function", user_arguments)
    facade = runner.getStringArgumentValue("facade", user_arguments)
    wwr = runner.getDoubleArgumentValue("wwr", user_arguments)
    offset = runner.getDoubleArgumentValue("offset", user_arguments)
    offset_si = OpenStudio.convert(offset, "in", "m").get

    # check arguments fo reasonableness
    if wwr <= 0 or wwr >= 1
      runner.registerError("Window to wall ratio must be greater than 0 and less than 1.")
      return false
    end

    if offset <= 0
      runner.registerError("Height offset must be > 0.")
      return false
    elsif offset > 360
      runner.registerWarning("Height offset seems unusually high: #{offset} inches")
    elsif offset > 9999
      runner.registerError("Height offset is above the limit for sill height: #{offset} inches")
      return false
    end
# TODO - need?
    #setup OpenStudio units that we will need
    unit_offset_ip = OpenStudio::createUnit("ft").get
    unit_offset_si = OpenStudio::createUnit("m").get
    unit_area_ip = OpenStudio::createUnit("ft^2").get
    unit_area_si = OpenStudio::createUnit("m^2").get
    unit_cost_per_area_ip = OpenStudio::createUnit("1/ft^2").get #$/ft^2 does not work
    unit_cost_per_area_si = OpenStudio::createUnit("1/m^2").get

    #define starting units
    offset_ip = OpenStudio::Quantity.new(offset/12, unit_offset_ip)

    #unit conversion
    offset_si = OpenStudio::convert(offset_ip, unit_offset_si).get

    #hold data for initial condition
    starting_gross_ext_wall_area = 0.0 # includes windows and doors
    starting_ext_window_area = 0.0

    #hold data for final condition
    final_gross_ext_wall_area = 0.0 # includes windows and doors
    final_ext_window_area = 0.0

    #flag for not applicable
    exterior_walls = false
    windows_added = false

    #flag to track notifications of zone multipliers
    space_warning_issued = []

    #flag to track warning for new windows without construction
    empty_const_warning = false

    #calculate initial envelope cost as negative value
    envelope_cost = 0
    constructions = model.getConstructions
    constructions.each do |construction|
      const_llcs = construction.lifeCycleCosts
      const_llcs.each do |const_llc|
        if const_llc.category == "Construction"
          envelope_cost += const_llc.totalCost*-1
        end
      end
    end #end of constructions.each do

    # MAIN CODE BLOCK

    # reporting
    runner.registerInfo("Function = #{function}")
    runner.registerInfo("Facade = #{facade}")
    runner.registerInfo("WWR = #{wwr}")
    runner.registerInfo("Sill Height = #{offset}")

    # loop through surfaces finding exterior walls with proper orientation
    surfaces = model.getSurfaces
    surfaces.each do |s|

      next if not s.surfaceType == "Wall"
      next if not s.outsideBoundaryCondition == "Outdoors"
      #skip if adding windows
      subsurfaces = s.subSurfaces
      next if subsurfaces.size > 0 && function == "Add"

      if s.space.empty?
        runner.registerWarning("#{s.name} doesn't have a parent space and won't be included in the measure reporting or modifications.")
        next
      end

      #get the absoluteAzimuth for the surface so we can categorize it
      absoluteAzimuth = OpenStudio::convert(s.azimuth,"rad","deg").get + s.space.get.directionofRelativeNorth + model.getBuilding.northAxis
      until absoluteAzimuth < 360.0
        absoluteAzimuth = absoluteAzimuth - 360.0
      end

      if facade == "North"
        next if not (absoluteAzimuth >= 315.0 or absoluteAzimuth < 45.0)
      elsif facade == "East"
        next if not (absoluteAzimuth >= 45.0 and absoluteAzimuth < 135.0)
      elsif facade == "South"
        next if not (absoluteAzimuth >= 135.0 and absoluteAzimuth < 225.0)
      elsif facade == "West"
        next if not (absoluteAzimuth >= 225.0 and absoluteAzimuth < 315.0)
      else
        runner.registerError("Unexpected value of facade: " + facade + ".")
        return false
      end
      exterior_walls = true

      #get surface area adjusting for zone multiplier
      space = s.space
      if not space.empty?
        zone = space.get.thermalZone
      end
      if not zone.empty?
        zone_multiplier = zone.get.multiplier
        if zone_multiplier > 1 and not space_warning_issued.include?(space.get.name.to_s)
          runner.registerInfo("Space #{space.get.name.to_s} in thermal zone #{zone.get.name.to_s} has a zone multiplier of #{zone_multiplier}. Adjusting area calculations.")
          space_warning_issued << space.get.name.to_s
        end
      else
        zone_multiplier = 1 #space is not in a thermal zone
        runner.registerWarning("Space #{space.get.name.to_s} is not in a thermal zone and won't be included in in the simulation. Windows will still be altered with an assumed zone multiplier of 1")
      end
      surface_gross_area = s.grossArea * zone_multiplier

      #loop through sub surfaces and add area including multiplier
      ext_window_area = 0

      s.subSurfaces.each do |subSurface|
        ext_window_area = ext_window_area + subSurface.grossArea * subSurface.multiplier * zone_multiplier
        if subSurface.multiplier > 1
          runner.registerInfo("Sub-surface #{subSurface.name.to_s} in space #{space.get.name.to_s} has a sub-surface multiplier of #{subSurface.multiplier}. Adjusting area calculations.")
        end
      end

      starting_gross_ext_wall_area += surface_gross_area
      starting_ext_window_area += ext_window_area

      # NEW
      runner.registerInfo("Number of subsurfaces within #{s.name}: #{subsurfaces.size}")

      if function == "Remove"

        subsurfaces.each do |ss|
          runner.registerInfo("Removing Window: #{ss.name}")
          ss.remove
        end

      elsif function == "Add" || function == "Replace"

        runner.registerInfo("Adding Window to Model")

        # add window
        new_window = s.setWindowToWallRatio(wwr, offset_si.value, true)
        if new_window.empty?
          runner.registerWarning("The requested window to wall ratio for surface '#{s.name}' was too large. Fenestration was not altered for this surface.")
        else
          windows_added = true
          #warn user if resulting window doesn"t have a construction, as it will result in failed simulation. In the future may use logic from starting windows to apply construction to new window.
          if new_window.get.construction.empty? and empty_const_warning == false
            runner.registerWarning("one or more resulting windows do not have constructions. This script is intended to be used with models using construction sets versus hard assigned constructions.")
            empty_const_warning = true
          end
        end

      else
        runner.registerInfo("MODEL NOT MODIFIED")
      end #NEW
    end #end of surfaces.each do

    #report initial condition wwr
    #the initial and final ratios does not currently account for either sub-surface or zone multipliers.
    starting_wwr = sprintf("%.02f",(starting_ext_window_area/starting_gross_ext_wall_area))
    runner.registerInitialCondition("The model's initial window to wall ratio for #{facade} facing exterior walls was #{starting_wwr}.") #TODO

    if not exterior_walls
      runner.registerAsNotApplicable("The model has no exterior #{facade.downcase} walls and was not altered")
      return true
    elsif not windows_added
      runner.registerAsNotApplicable("The model has exterior #{facade.downcase} walls, but no windows could be added with the requested window to wall ratio")
      return true
    end

    #data for final condition wwr
    surfaces = model.getSurfaces
    surfaces.each do |s|
      next if not s.surfaceType == "Wall"
      next if not s.outsideBoundaryCondition == "Outdoors"
      if s.space.empty?
        runner.registerWarning("#{s.name} doesn't have a parent space and won't be included in the measure reporting or modifications.")
        next
      end

      # get the absoluteAzimuth for the surface so we can categorize it
      absoluteAzimuth =  OpenStudio::convert(s.azimuth,"rad","deg").get + s.space.get.directionofRelativeNorth + model.getBuilding.northAxis
      until absoluteAzimuth < 360.0
        absoluteAzimuth = absoluteAzimuth - 360.0
      end

      if facade == "North"
        next if not (absoluteAzimuth >= 315.0 or absoluteAzimuth < 45.0)
      elsif facade == "East"
        next if not (absoluteAzimuth >= 45.0 and absoluteAzimuth < 135.0)
      elsif facade == "South"
        next if not (absoluteAzimuth >= 135.0 and absoluteAzimuth < 225.0)
      elsif facade == "West"
        next if not (absoluteAzimuth >= 225.0 and absoluteAzimuth < 315.0)
      else
        runner.registerError("Unexpected value of facade: " + facade + ".")
        return false
      end

      #get surface area adjusting for zone multiplier
      space = s.space
      if not space.empty?
        zone = space.get.thermalZone
      end
      if not zone.empty?
        zone_multiplier = zone.get.multiplier
        if zone_multiplier > 1
        end
      else
        zone_multiplier = 1 #space is not in a thermal zone
      end
      surface_gross_area = s.grossArea * zone_multiplier

      #loop through sub surfaces and add area including multiplier
      ext_window_area = 0
      s.subSurfaces.each do |subSurface| #onlky one and should have multiplier of 1
        ext_window_area = ext_window_area + subSurface.grossArea * subSurface.multiplier * zone_multiplier
      end

      final_gross_ext_wall_area += surface_gross_area
      final_ext_window_area += ext_window_area
    end #end of surfaces.each do

    #short def to make numbers pretty (converts 4125001.25641 to 4,125,001.26 or 4,125,001). The definition be called through this measure
    def neat_numbers(number, roundto = 2) #round to 0 or 2)
      # round to zero or two decimals
      if roundto == 2
        number = sprintf "%.2f", number
      else
        number = number.round
      end
      #regex to add commas
      number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
    end #end def pretty_numbers

    #get delta in ft^2 for final - starting window area
    increase_window_area_si = OpenStudio::Quantity.new(final_ext_window_area - starting_ext_window_area, unit_area_si)
    increase_window_area_ip = OpenStudio::convert(increase_window_area_si, unit_area_ip).get

    #calculate final envelope cost as positive value
    constructions = model.getConstructions
    constructions.each do |construction|
      const_llcs = construction.lifeCycleCosts
      const_llcs.each do |const_llc|
        if const_llc.category == "Construction"
          envelope_cost += const_llc.totalCost
        end
      end
    end #end of constructions.each do

    #report final condition
    final_wwr = sprintf("%.02f",(final_ext_window_area/final_gross_ext_wall_area))
    runner.registerFinalCondition("The model's final window to wall ratio for #{facade} facing exterior walls is #{final_wwr}. Window area increased by #{neat_numbers(increase_window_area_ip.value,0)} (ft^2). The material and construction costs increased by $#{neat_numbers(envelope_cost,0)}.")

    return true

  end #end the run method

end #end the measure

#this allows the measure to be use by the application
AddRemoveOrReplaceWindowsByFacade.new.registerWithApplication

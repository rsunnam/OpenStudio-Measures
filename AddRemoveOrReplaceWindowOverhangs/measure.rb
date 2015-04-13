# start the measure
class AddRemoveOrReplaceWindowOverhangs < OpenStudio::Ruleset::ModelUserScript

  # define the name that the user will see
  def name
    return "Add Remove Or Replace Window Overhangs"
  end

  # define the arguments that the user will input
  def arguments(model)

    # create arguments vector
    args = OpenStudio::Ruleset::OSArgumentVector.new

    # function
    function_choices = OpenStudio::StringVector.new
    function_choices << "Add"
    function_choices << "Remove"
    function_choices << "Replace"
    function = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("function", function_choices, true)
    function.setDisplayName("Function")
    args << function

    # facade
    facade_choices = OpenStudio::StringVector.new
    facade_choices << "All"
    facade_choices << "North"
    facade_choices << "East"
    facade_choices << "South"
    facade_choices << "West"
    facade = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("facade", facade_choices, true)
    facade.setDisplayName("Facade")
    args << facade

    # depth
    depth = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("depth", false)
    depth.setDisplayName("Depth (in)")
    #depth.setDescription("Depth offset required if adding overhang by depth.")
    args << depth

    # depth offset
    depth_offset = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("depth_offset", false)
    depth_offset.setDisplayName("Depth Offset (in)")
    depth_offset.setDescription("height and width offset from window edge")
    depth_offset.setDefaultValue(0)
    args << depth_offset

    # projection factor
    projection_factor = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("projection_factor", false)
    projection_factor.setDisplayName("Projection Factor (fraction)")
    projection_factor.setDescription("overhang depth / window height")
    args << projection_factor

    # projection factor offset
    projection_factor_offset = OpenStudio::Ruleset::OSArgument::makeDoubleArgument("projection_factor_offset", false)
    projection_factor_offset.setDisplayName("Projection Factor Offset (fraction)")
    projection_factor_offset.setDescription("height and width offset from window edge") #TODO
    projection_factor_offset.setDefaultValue(0)
    args << projection_factor_offset

    #populate choice argument for constructions that are applied to surfaces in the model
    construction_handles = OpenStudio::StringVector.new
    construction_display_names = OpenStudio::StringVector.new

    #putting space types and names into hash
    construction_args = model.getConstructions
    construction_args_hash = {}
    construction_args.each do |construction_arg|
      construction_args_hash[construction_arg.name.to_s] = construction_arg
    end

    #looping through sorted hash of constructions
    construction_args_hash.sort.map do |key,value|
      #only include if construction is not used on surface
      if not value.isFenestration
        construction_handles << value.handle.to_s
        construction_display_names << key
      end
    end

    #make an argument for construction
    construction = OpenStudio::Ruleset::OSArgument::makeChoiceArgument("construction", construction_handles, construction_display_names, false)
    construction.setDisplayName("Optionally Choose a Construction for the Overhangs.")
    args << construction

    # return arguments vector
    return args

  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)

    super(model, runner, user_arguments)

    # use the built-in error checking
    if not runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # assign user inputs to variables, check, and convert to SI units for simulation
    function = runner.getStringArgumentValue("function", user_arguments)
    facade = runner.getStringArgumentValue("facade", user_arguments)

    depth = runner.getOptionalDoubleArgumentValue("depth", user_arguments)
    depth_too_small = false
    if depth.is_initialized
      depth = depth.get
      if depth < 0
        runner.registerError("Depth must be > 0")
        return false
      elsif depth < 1
        runner.registerWarning("Depth seems unusually small, check input.")
        depth_too_small = true
      end
      depth_si = OpenStudio.convert(depth,"in","m").get
    else
      depth = nil
    end

    depth_offset = runner.getDoubleArgumentValue("depth_offset", user_arguments)
    depth_offset_too_small = false
    if depth_offset < 0
      runner.registerError("Depth offset must be > 0")
      return false
'    elsif depth_offset < 1
      runner.registerWarning("Depth offset seems unusually small, check input.") #TODO and not function == "Remove"
      depth_offset_too_small = true
'    end
    depth_offset_si = OpenStudio.convert(depth_offset, "in", "m").get

    projection_factor = runner.getOptionalDoubleArgumentValue("projection_factor", user_arguments)
    projection_factor_too_small = false
    if projection_factor.is_initialized
      projection_factor = projection_factor.get
      if projection_factor < 0
        runner.registerError("Projection factor must be > 0")
        return false
      elsif projection_factor < 0.1
        runner.registerWarning("Projection factor seems unusually small, check input.")
        projection_factor_too_small = true
      elsif projection_factor > 5
        runner.registerWarning("Projection factor seems unusually large, check input.")
      end
    else
      projection_factor = nil
    end

    projection_factor_offset = runner.getDoubleArgumentValue("projection_factor_offset", user_arguments)
    if projection_factor_offset < 0
      runner.registerError("Depth offset must be > 0")
      return false
'    elsif projection_factor_offset < 1
      runner.registerWarning("Depth offset seems unusually small, check input.")
      depth_offset_too_small = true
'    end

    construction = runner.getOptionalWorkspaceObjectChoiceValue("construction",user_arguments,model)
    construction_chosen = true
    if construction.empty?
      handle = runner.getOptionalStringArgumentValue("construction",user_arguments)
      if handle.empty?
        runner.registerInfo("No construction was chosen.")
        construction_chosen = false
      else
        runner.registerError("The selected construction with handle '#{handle}' was not found in the model. It may have been removed by another measure.")
        return false
      end
    else
      if not construction.get.to_Construction.empty?
        construction = construction.get.to_Construction.get
      else
        runner.registerError("Script Error - argument not showing up as construction.")
        return false
      end
    end

    # helper to make numbers pretty (converts 4125001.25641 to 4,125,001.26 or 4,125,001). The definition be called through this measure.
    def neat_numbers(number, roundto = 2) #round to 0 or 2)
      if roundto == 2
        number = sprintf "%.2f", number
      else
        number = number.round
      end
      #regex to add commas
      number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
    end #end def neat_numbers

    # helper to make it easier to do unit conversions on the fly. The definition be called through this measure.
    def unit_helper(number,from_unit_string,to_unit_string)
      converted_number = OpenStudio::convert(OpenStudio::Quantity.new(number, OpenStudio::createUnit(from_unit_string).get), OpenStudio::createUnit(to_unit_string).get).get.value
    end

    # helper that loops through lifecycle costs getting total costs under "Construction" or "Salvage" category and add to counter if occurs during year 0
    def get_total_costs_for_objects(objects)
      counter = 0
      objects.each do |object|
        object_LCCs = object.lifeCycleCosts
        object_LCCs.each do |object_LCC|
          if object_LCC.category == "Construction" or object_LCC.category == "Salvage"
            if object_LCC.yearsFromStart == 0
              counter += object_LCC.totalCost
            end
          end
        end
      end
      return counter
    end #end of def get_total_costs_for_objects(objects)

    # counter for year 0 capital costs
    yr0_capital_totalCosts = 0

    # get initial construction costs and multiply by -1
    yr0_capital_totalCosts +=  get_total_costs_for_objects(model.getConstructions)*-1


    # initialize variables
    remove_count = 0
    add_replace_count = 0

    # get model objects
    shading_groups = model.getShadingSurfaceGroups
    subsurfaces = model.getSubSurfaces

    # report initial condition
    number_of_exist_space_shading_surf = 0
    shading_groups.each do |shading_group|
      if shading_group.shadingSurfaceType == "Space"
        number_of_exist_space_shading_surf = number_of_exist_space_shading_surf + shading_group.shadingSurfaces.size
      end
    end
    runner.registerInitialCondition("overhangs = #{number_of_exist_space_shading_surf}")

    # MAIN

    if function == "Remove"

      shading_groups.each do |shading_group|
        if shading_group.shadingSurfaceType == "Space"
          shading_group.remove
          remove_count += 1
        end
      end

#      runner.registerInfo("overhangs removed = #{remove_count}")

      # flag for not applicable
      overhang_added = false

    else #if function == "Add" or function == "Replace"
      #loop through surfaces finding exterior walls with proper orientation
      subsurfaces.each do |s|

        next if not s.outsideBoundaryCondition == "Outdoors"
        next if s.subSurfaceType == "Skylight"
        next if s.subSurfaceType == "Door"
        next if s.subSurfaceType == "GlassDoor"
        next if s.subSurfaceType == "OverheadDoor"
        next if s.subSurfaceType == "TubularDaylightDome"
        next if s.subSurfaceType == "TubularDaylightDiffuser"

        # get subsurface azimuth to determine facade
        azimuth = OpenStudio::Quantity.new(s.azimuth, OpenStudio::createSIAngle)
        azimuth = OpenStudio.convert(azimuth, OpenStudio::createIPAngle).get.value

        if not facade == "All"

          if facade == "North"
            next if not (azimuth >= 315.0 or azimuth < 45.0)
          elsif facade == "East"
            next if not (azimuth >= 45.0 and azimuth < 135.0)
          elsif facade == "South"
            next if not (azimuth >= 135.0 and azimuth < 225.0)
          elsif facade == "West"
            next if not (azimuth >= 225.0 and azimuth < 315.0)
          else
            runner.registerError("Unexpected value of facade: " + facade + ".")
            return false
          end

        end

        # delete existing overhang if one already exists TODO
        shading_groups.each do |shading_group|
          shading_s = shading_group.shadingSurfaces
          shading_s.each do |ss|
            if ss.name.to_s == "#{s.name.to_s} - Overhang"
              ss.remove
              runner.registerWarning("Removed pre-existing window shade named '#{ss.name}'.")
            end
          end
        end

        projection_factor_too_small = false
        if projection_factor_too_small
          # new overhang would be too small and would cause errors in OpenStudio
          # don"t actually add it, but from the measure"s perspective this worked as requested
          overhang_added = true
        else
          # add the overhang
          if not depth.nil? and not projection_factor.nil? #empty? doesn't work on float or nil types
            runner.registerError("Overhangs can only be added by entering a depth and offset or by entering a projection factor.")
            new_overhang = nil
          elsif not depth.nil? and depth_offset == nil
            runner.registerError("Depth offset required if adding overhangs by depth.")
          elsif not depth.nil?
            new_overhang = s.addOverhang(depth_si, depth_offset_si)
          elsif not projection_factor.nil?
            new_overhang = s.addOverhangByProjectionFactor(projection_factor, projection_factor_offset)
          end
  #TODO error for no inputs
          if new_overhang.nil?
            ok = runner.registerWarning("Unable to add overhang to " + s.briefDescription +
                     " with projection factor " + projection_factor.to_s + " and offset " + offset.to_s + ".")
            return false if not ok
          else
            new_overhang.get.setName("#{s.name} - Overhang")
'            runner.registerInfo("Added overhang " + new_overhang.get.briefDescription + " to " +
                s.briefDescription + " with depth " + depth.to_s +
                " and offset " + "0" + ".")
'
            if construction_chosen
              if not construction.  to_Construction.empty?
                new_overhang.get.setConstruction(construction)
              end
            end
            overhang_added = true
          end
          add_replace_count += 1
        end

      end #end subsurfaces.each do |s|

    end #add or replace

    if not overhang_added and not function == "Remove"
      runner.registerAsNotApplicable("The model has exterior #{facade.downcase} walls, but no windows were found to add overhangs to.")
      return true
    end

    #get final construction costs and multiply
    yr0_capital_totalCosts +=  get_total_costs_for_objects(model.getConstructions)

    # report final condition
    number_of_final_space_shading_surf = 0
    final_shading_groups = model.getShadingSurfaceGroups
    final_shading_groups.each do |shading_group|
      number_of_final_space_shading_surf = number_of_final_space_shading_surf + shading_group.shadingSurfaces.size
    end
    runner.registerFinalCondition("overhangs = #{number_of_final_space_shading_surf}")

    if function == "Add" or function == "Replace"
      runner.registerInfo("overhangs added or replaced = #{add_replace_count}")
    elsif function == "Remove"
      runner.registerInfo("overhangs removed = #{remove_count}")
    end
#    runner.registerWarning("Initial capital costs associated with the improvements are $#{neat_numbers(yr0_capital_totalCosts,0)}.")

    return true

  end #end the run method

end #end the measure

#this allows the measure to be use by the application
AddRemoveOrReplaceWindowOverhangs.new.registerWithApplication

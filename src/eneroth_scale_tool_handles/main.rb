# Eneroth Scale Tool Handles

# Copyright Julia Christina Eneroth, eneroth3@gmail.com

module EneScaleToolHandles

  Sketchup.require(File.join(PLUGIN_DIR, "bitmask"))

  # Wrapper class to handle scale handle masks.
  # Instead of setting each type of handle separately this wrapper
  # handles each axes, 2D diagonals and 3D diagonals.
  class ScaleController

    NO_X_SCALE   = 0
    NO_Y_SCALE   = 1
    NO_Z_SCALE   = 2
    NO_XZ_SCALE  = 3
    NO_YZ_SCALE  = 4
    NO_XY_SCALE  = 5
    NO_XYZ_SCALE = 6

    SCALE_TOOL_ID = 21236

    def initialize(definition)
      @definition = definition
      # API has ? at end of method even though it returns integer.
      @no_scale_mask = BitMask.new(definition.behavior.no_scale_mask?)
    end

    # REVIEW: These methods are very similar. Can they be created using meta-programming?

    def axis_x=(v)
      if diagonal_2d? || !diagonal_2d_enabled?
        @no_scale_mask[NO_XY_SCALE] = !v
        @no_scale_mask[NO_XZ_SCALE] = !v
      end
      if diagonal_3d? || !diagonal_3d_enabled?
         @no_scale_mask[NO_XYZ_SCALE] = !v
      end
      @no_scale_mask[NO_X_SCALE] = !v
      apply
    end

    def axis_x?
      !@no_scale_mask[NO_X_SCALE]
    end

    def axis_y=(v)
      if diagonal_2d? || !diagonal_2d_enabled?
        @no_scale_mask[NO_XY_SCALE] = !v
        @no_scale_mask[NO_YZ_SCALE] = !v
      end
      if diagonal_3d? || !diagonal_3d_enabled?
         @no_scale_mask[NO_XYZ_SCALE] = !v
      end
      @no_scale_mask[NO_Y_SCALE] = !v
      apply
    end

    def axis_y?
      !@no_scale_mask[NO_Y_SCALE]
    end

    def axis_z=(v)
      if diagonal_2d? || !diagonal_2d_enabled?
        @no_scale_mask[NO_XZ_SCALE] = !v
        @no_scale_mask[NO_YZ_SCALE] = !v
      end
      if diagonal_3d? || !diagonal_3d_enabled?
         @no_scale_mask[NO_XYZ_SCALE] = !v
      end
      @no_scale_mask[NO_Z_SCALE] = !v
      apply
    end

    def axis_z?
      !@no_scale_mask[NO_Z_SCALE]
    end

    def diagonal_2d=(v)
      @no_scale_mask[NO_XY_SCALE] = !(axis_x? && axis_y? && v)
      @no_scale_mask[NO_XZ_SCALE] = !(axis_x? && axis_z? && v)
      @no_scale_mask[NO_YZ_SCALE] = !(axis_y? && axis_z? && v)
      apply
    end

    def diagonal_2d?
      !@no_scale_mask[NO_XY_SCALE] || !@no_scale_mask[NO_XZ_SCALE] || !@no_scale_mask[NO_YZ_SCALE]
    end

    def diagonal_2d_enabled?
      [axis_x?, axis_y?, axis_z?].count(true) >= 2
    end

    def diagonal_3d=(v)
      @no_scale_mask[NO_XYZ_SCALE] = !(axis_x? && axis_y? && axis_z? && v)
      apply
    end

    def diagonal_3d?
      !@no_scale_mask[NO_XYZ_SCALE]
    end

    def diagonal_3d_enabled?
      axis_x? && axis_y? && axis_z?
    end

    def inspect
      @no_scale_mask.inspect
    end

    private

    def apply
      @definition.behavior.no_scale_mask = @no_scale_mask.to_i

      # Update handles in Scale Tool by re-selecting the current selection.
      if @definition.model.tools.active_tool_id == SCALE_TOOL_ID
        selection = @definition.model.selection
        selected = selection.to_a
        selection.clear
        selection.add(selected)
      end

      nil
    end

  end

  # Reload whole extension (except loader) without littering
  # console. Inspired by ThomTohm's method.
  # Only works before extension has been scrambled.
  #
  # clear_console - Clear console from previous content too (default: false)
  #
  # Returns nothing.
  def self.reload(clear_console = false, undo = false)
    # Hide warnings for already defined constants.
    verbose = $VERBOSE
    $VERBOSE = nil
    Dir.glob(File.join(PLUGIN_DIR, "*.rb")).each { |f| load(f) }
    $VERBOSE = verbose

    # Use a timer to make call to method itself register to console.
    # Otherwise the user cannot use up arrow to repeat command.
    UI.start_timer(0) { SKETCHUP_CONSOLE.clear } if clear_console

    Sketchup.undo if undo

    nil
  end

  unless file_loaded?(__FILE__)
    file_loaded(__FILE__)
    UI.add_context_menu_handler do |menu|
      model = Sketchup.active_model
      next unless model.selection.size == 1
      entity = model.selection.first
      next unless [Sketchup::ComponentInstance, Sketchup::Group].include?(entity.class)
      sc = ScaleController.new(entity.definition)

      menu.add_separator
      menu = menu.add_submenu(EXTENSION.name)

      item = menu.add_item("Red Axis") { sc.axis_x = !sc.axis_x? }
      menu.set_validation_proc(item)  { sc.axis_x? ? MF_CHECKED : MF_UNCHECKED }

      item = menu.add_item("Green Axis") { sc.axis_y = !sc.axis_y? }
      menu.set_validation_proc(item)  { sc.axis_y? ? MF_CHECKED : MF_UNCHECKED }

      item = menu.add_item("Blue Axis") { sc.axis_z = !sc.axis_z? }
      menu.set_validation_proc(item)  { sc.axis_z? ? MF_CHECKED : MF_UNCHECKED }

      menu.add_separator

      item = menu.add_item("2D Diagonals") { sc.diagonal_2d = !sc.diagonal_2d? }
      menu.set_validation_proc(item)   { sc.diagonal_2d_enabled? ? (sc.diagonal_2d? ? MF_CHECKED : MF_UNCHECKED) : MF_GRAYED }

      item = menu.add_item("3D Diagonals") { sc.diagonal_3d = !sc.diagonal_3d? }
      menu.set_validation_proc(item)   { sc.diagonal_3d_enabled? ? (sc.diagonal_3d? ? MF_CHECKED : MF_UNCHECKED) : MF_GRAYED }
    end
  end

end

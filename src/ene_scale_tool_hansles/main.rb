# Eneroth Scale Tool Handles

# Copyright Julia Christina Eneroth, eneroth3@gmail.com

module EneScaleToolHandles

  Sketchup.require(File.join(PLUGIN_DIR, "bitmask"))

  # Wrapper class to handle scale handle masks.
  # Instead of setting each type of handle separately this wrapper
  # handles each axes, 2D diagonals and 3D diagonals.
  class ScaleMask

    NO_X_SCALE   = 0
    NO_Y_SCALE   = 1
    NO_Z_SCALE   = 2
    NO_XZ_SCALE  = 3
    NO_YZ_SCALE  = 4
    NO_XY_SCALE  = 5
    NO_XYZ_SCALE = 6

    def initialize(definition)
      @definition = definition
      # API has ? at end of method even though it returns integer.
      @no_scale_mask = BitMask.new(definition.behavior.no_scale_mask?)
    end

    # REVIEW: These methods are very similar. Can they be created using meta-programming?

    def allow_x=(v)
      # TODO: If diagonals have been unavailable, assume user wants to make them available again.
      if allow_2d?
        @no_scale_mask[NO_XY_SCALE] = !v
        @no_scale_mask[NO_XZ_SCALE] = !v
      end
      if allow_3d?
         @no_scale_mask[NO_XYZ_SCALE] = !v
      end
      @no_scale_mask[NO_X_SCALE] = !v
      apply
    end

    def allow_x?
      !@no_scale_mask[NO_X_SCALE]
    end

    def allow_y=(v)
      if allow_2d?
        @no_scale_mask[NO_XY_SCALE] = !v
        @no_scale_mask[NO_YZ_SCALE] = !v
      end
      if allow_3d?
         @no_scale_mask[NO_XYZ_SCALE] = !v
      end
      @no_scale_mask[NO_Y_SCALE] = !v
      apply
    end

    def allow_y?
      !@no_scale_mask[NO_Y_SCALE]
    end

    def allow_z=(v)
      if allow_2d?
        @no_scale_mask[NO_XZ_SCALE] = !v
        @no_scale_mask[NO_YZ_SCALE] = !v
      end
      if allow_3d?
         @no_scale_mask[NO_XYZ_SCALE] = !v
      end
      @no_scale_mask[NO_Z_SCALE] = !v
      apply
    end

    def allow_z?
      !@no_scale_mask[NO_Z_SCALE]
    end

    def allow_2d=(v)
      @no_scale_mask[NO_XY_SCALE] = !(allow_x? && allow_y? && v)
      @no_scale_mask[NO_XZ_SCALE] = !(allow_x? && allow_z? && v)
      @no_scale_mask[NO_YZ_SCALE] = !(allow_y? && allow_z? && v)
      apply
    end

    def allow_2d?
      !@no_scale_mask[NO_XY_SCALE] || !@no_scale_mask[NO_XZ_SCALE] || !@no_scale_mask[NO_YZ_SCALE]
    end

    def avilable_2d?
      [allow_x?, allow_y?, allow_z?].count(true) >= 2
    end

    def allow_3d=(v)
      @no_scale_mask[NO_XYZ_SCALE] = !(allow_x? && allow_y? && allow_z? && v)
      apply
    end

    def allow_3d?
      !@no_scale_mask[NO_XYZ_SCALE]
    end

    def available_3d?
      allow_x? && allow_y? && allow_z?
    end

    def inspect
      @no_scale_mask.inspect
    end

    private

    def apply
      @definition.behavior.no_scale_mask = @no_scale_mask.to_i
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
      ms = ScaleMask.new(entity.definition)

      item = menu.add_item("Scale X") { ms.allow_x = !ms.allow_x? }
      menu.set_validation_proc(item)  { ms.allow_x? ? MF_CHECKED : MF_UNCHECKED }

      item = menu.add_item("Scale Y") { ms.allow_y = !ms.allow_y? }
      menu.set_validation_proc(item)  { ms.allow_y? ? MF_CHECKED : MF_UNCHECKED }

      item = menu.add_item("Scale Z") { ms.allow_z = !ms.allow_z? }
      menu.set_validation_proc(item)  { ms.allow_z? ? MF_CHECKED : MF_UNCHECKED }

      menu.add_separator

      item = menu.add_item("Scale 2D") { ms.allow_2d = !ms.allow_2d? }
      menu.set_validation_proc(item)   { ms.avilable_2d? ? (ms.allow_2d? ? MF_CHECKED : MF_UNCHECKED) : MF_GRAYED }
      item = menu.add_item("Scale 3D") { ms.allow_3d = !ms.allow_3d? }
      menu.set_validation_proc(item)   { ms.available_3d? ? (ms.allow_3d? ? MF_CHECKED : MF_UNCHECKED) : MF_GRAYED }
    end
  end

end

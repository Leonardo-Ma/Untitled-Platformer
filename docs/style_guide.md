# Code Style Guide

This style guide is separated into three parts: code rules, other file rules, and guidelines for git.

The style rules are intended to increase readability of the source code for humans that will read the written code. The most important rule of all is: Use common sense. 

## Code style rules

- Indentation is 4 spaces. Continued statements are indented one level
  higher.

- Names (that includes variables, functions and classes) should be
  descriptive. Avoid abbreviations. Do not shorten variable names just
  to save key strokes, it will be read far more often than it will be
  written. Single character variable names can be used in for
  loops. They should be avoided everywhere else.

- Some common short names are accepted (and even preferred): i, k, a,
  b used in loops (x, y, z used in loops that deal with coordinates or
  math), e used in `catch` blocks as the exception name. Other
  variables in loops and elsewhere need to be named with actually
  descriptive variable names.
  
- Similarly, some very common abbreviations are used in the code,
  and can (and should) thus be used when naming variables. These are
  however *rare* exceptions, not the rule. The allowed abbreviations 
  are listed below. No other abbreviation should be used.
  - `min` - `max` - `pos` - `rot` - `str`
  - `rect` (when related to class names and variables holding instances of those classes)
  - `tech` (short for technology)

- Variables and functions are `camelCase`. Classes are `PascalCase`. Constants are `UPPER_SNAKE_CASE`. Enums are `UPPERCASE`

- Files inside `/scr` and Godot related are snake_case. 
- - Only exception: [ScriptTemplates](https://docs.godotengine.org/en/stable/tutorials/scripting/creating_script_templates.html)
- - 

- Start comments with a capital letter, unless it is a commented out
  code block or a keyword.

- Empty lines are encouraged between blocks of code to improve
  readability. Blank space is your friend, not your enemy. Separate
  out logically different parts of a method with blank lines.

- Use preincrement (`++i`) in loops and other cases, unless you
  actually need post increment.

- Ternary operators (`condition ? exprIfTrue : exprIfFalse`) can be used instead of `if ... else`
  statements as long as they are kept readable. 
  
- Single line variables (and properties) can be next to each other
  without a blank line. Other variables and class elements should have
  a blank line separating them.

- Don't declare multiple local variables on the same line, instead
  place each declaration on its own line

- Properties should be very strongly preferred over getter or setter
  methods. Only when a parameter is needed, is a getter method a good
  idea.

- When setting things that might require validation going through a
  property should be preferred, even in the same class to avoid
  mistakes in skipping some logic by directly assigning a field.

- Unrelated uses should not share the same variable. Instead they
  should locally define their own variable instance.

- Avoid globals. Especially in object trees where you can easily
  enough pass the reference along.

-- Do not use `string.Format` with a translated format string, as
  translation mistakes can crash the game in that case. Instead either
  use `LocalizedString`, `LocalizedStringBuilder`, or
  `StringUtils.FormatSafe`. Those ways will automatically catch
  exceptions from broken translations and return the format string
  un-formatted. `StringUtils` will likely want to be invoked as an
  extension method on the string (`"example".FormatSafe(...)`). If the
  format string is not user supplied, normal `string.Format` is allowed,
  but should be passed `CultureInfo.CurrentCulture` as the first
  parameter as we want text shown to the user in the user's selected
  locale.

- Prefer early returns in methods to avoid unnecessary
  indentation. Check assumptions about the parameters of a method at
  the start and return early with an error if the inputs are not
  valid.

-- Use `TryGetValue` instead of first calling `Dictionary.ContainsKey`
  and then reading the value separate because `TryGetValue` is faster.

- Defensive programming is recommended. The idea is to write code that
  expects other parts of the codebase to mess up somewhere. For example,
  when checking for health, instead of checking
  `health == 0`, it is recommended to do `health <= 0` to guard
  against negative health bugs.

- Separation of concerns should be used.
  
- When writing conditions checking booleans, don't explicitly write
  out `true` or `false` (unless the variable is nullable in which case
  the explicit compare is required). So write code like this: `if
  (thing)` and not: `if (thing == true)`.

- Finally you should attempt to reach the abstract goal of clean
  code. Here are some concepts that are indicative of good code (and
  breaking these can be bad code): Liskov substitution principle,
  single purpose principle, logically putting same kind of code in the
  same place, avoid repetition, avoid expensive operations in a loop,
  prefer simpler code to understand. Avoid anti-patterns, for example
  God class.

## Godot usage

- GUIs need to be usable with the mouse and a controller. See
  [making_guis.md](making_guis.md).

- Do not use Control offsets to try to position elements, that's not good
  Godot usage. Use proper parent container and min size instead.

- For spacing elements use either a spacer (that has a visual
  appearance) or for invisible space use an empty Control with rect
  `minsize` set to the amount of blank you want.

- Don't use text in the GUI with leading or trailing spaces to add
  padding, see previous bullet instead.

- Node names should not contain spaces, instead use PascalCase naming.

- For connecting signals, use `nameof` to refer to methods whenever possible
  to reduce the chance of mistakes when methods are renamed.

- When destroying child Nodes or Controls take care to detach them
  first, in cases that having them hang around for one more frame
  causes issues, as that doesn't happen if you just call
  `QueueFree`. You can instead call `DetachAndQueueFree`
  instead to detach them from parents automatically.

- The order of Godot overridden methods in a class should be in the
  following order: (class constructor), `_Ready`, `_ExitTree`, `_Process`,
  `_Input`, `_UnhandledInput`, (other callbacks)

- To remove all children of a Node use `FreeChildren` or
  `QueueFreeChildren` extension methods.

- DO NOT DISPOSE Godot Node derived objects, call `QueueFree` or
  `Free` instead. Also don't override Dispose in Node derived types to
  detect when the Node is removed, instead use the tree enter and exit
  callbacks to handle resources that need releasing when removed.

- For scene attached Nodes, they do not need to be manually freed or
  disposed. Godot will automatically free them along with the parent.

- `NodePath` variables should be disposed as they aren't part of the
  scene tree or Godot properties it likely knows about. So disposing
  those variables will speed up their clearing.

- Avoid using a constructor to setup Godot resources, usually Node
  derived types should mostly do Godot Node related, constructor-like
  operations entirely in `_Ready`. Many resources are not ready yet when
  a class is constructed or static variables are being initialized. If
  this is not followed script variables may not show up correctly in
  the Godot editor as that relies on creating an instance of the
  class, and that can fail for example because SimulationParameters
  are not initialized in the Godot editor. This needs especial care
  when a class type is directly attached to a Godot scene.

- We have rewritten several controls to workaround Godot bugs or limitations,
  and add custom features. All these rewritten/customized controls are placed
  in `res://src/gui_common/`. Currently there are `CustomCheckBox`,
  `TopLevelContainer`, `CustomWindow`, `CustomConfirmationDialog`, `ErrorDialog`,
  `TutorialDialog`, `CustomDropDown`, `CustomRichTextLabel`, and
  `TweakedColourPicker`. Consider using these custom types rather than the
  built-in types to ensure consistency across the GUI.

- When you are instantiating a custom Control in Godot, use
  `Instance Child Scene` if it has a corresponding scene (.tscn) file; If it
  doesn't, add a corresponding built-in Control and use `Attach Script`.
  An alternative is to locate the scene or script file in `FileSystem` panel
  (by default on the bottom-left corner) and drag it to the proper position.

- Using built-in `Popup` is not recommended since a custom one tailored
  for the game already exist but for posterity similar rules in
  the above point still stands. In addition, don't use `Popup.Popup_`,
  instead prefer to use `Popup.Show` or `Popup.ShowModal`, only if those
  don't work then you can consider using `Popup.Popup_`.

- When using fonts, don't directly load the .ttf file with an embedded
  font in a scene file. Instead create a label settings in
  `src/gui_common/fonts` folder and use that. This is needed because
  fonts need to have settings like fallback fonts set, for example
  Chinese. All fonts should be TrueType (`.ttf`) and stored in
  `assets/fonts`. For variable weight fonts the variants created from
  the font should be placed in `assets/fonts/variants`. For buttons
  that cannot use label settings, it is preferrably to just set a
  theme font size override, but when really needed the override font
  can be set, but care needs to be taken that this points to a proper
  font. For variable weight fonts only the variants should be used and
  not the base font directly.

- All images used in the GUI should have mipmaps on in the import
  options.

Other recommended approaches
----------------------------

- When changing the meaning of a game setting in a major way that is
  incompatible with previous values, the updated setting should use a
  different name when saved in JSON to avoid problems. For example:
  `[JsonProperty(PropertyName = "MaxSpawnedEntitiesV2")]`. This way
  the options menu doesn't need complicated adapting logic as
  otherwise it would show misleading values to the player.

Other files
-----------

- Simulation configuration JSON files should be named using snake_case.

- JSON files need to be formatted with jsonlint. There is a CI check
  that will complain if they aren't. This is a part of the formatting
  check script.

- New JSON files should prefer PascalCase keys. Existing JSON files
  should stick to what other parts of that file use.

- Registry items (for example organelles) should use camelCase for their
  internal names (IRegistryType.InternalName), and not snake_case.
  Otherwise other names that follow the internal names will violate other
  naming conventions.

- Do not use `<br>` in markdown unless it is a table where line breaks
  need to be tightly controlled. Use blank lines instead of
  `<br>`. Also don't use `<hr>` use `---` instead.

- For translations see the specific instructions in
  [working_with_translations.md](working_with_translations.md)

Gameplay changes
----------------

When doing changes that impact existing gameplay or add new gameplay
additional considerations regarding playability and understandability
need to be taken into account.

- When changing an existing mechanic that has tutorials, tooltips, help 
  menu entries or other explanations, you must also update those texts
  so that how we explain the game to the player doesn't get out of sync.
  This is because if a gameplay changing PR is accepted it may take multiple
  months for anyone to bother to update the help text meanwhile players don't
  know about the new mechanics.

- For new gameplay features it is recommended but not mandatory to write
  new help text or tutorials to explain them.
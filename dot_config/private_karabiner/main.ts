import { map, rule, writeToGlobal, writeToProfile } from "karabinerts";

const PROFILE_NAME = "Default profile";

writeToGlobal({
  check_for_updates_on_startup: false,
  show_in_menu_bar: false,
  show_profile_name_in_menu_bar: false,
});

writeToProfile(PROFILE_NAME, [
  rule("Caps Lock -> Hyper, tap = Caps Lock").manipulators([
    map("caps_lock", "optionalAny")
      .to({
        key_code: "left_command",
        modifiers: ["option", "control", "shift"],
        lazy: true,
      })
      .toIfAlone({
        key_code: "caps_lock",
        hold_down_milliseconds: 200,
      }),
  ]),
]);

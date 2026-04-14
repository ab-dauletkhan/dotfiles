import {
  map,
  rule,
  writeToGlobal,
  writeToProfile,
} from "https://deno.land/x/karabinerts@1.36.0/deno.ts";

writeToGlobal({
  check_for_updates_on_startup: false,
  show_in_menu_bar: false,
  show_profile_name_in_menu_bar: false,
});

writeToProfile("Default", [
  rule("Caps Lock -> Hyper").manipulators([
    map("caps_lock").toHyper().toIfAlone("caps_lock"),
  ]),
]);

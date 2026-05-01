import { application } from "controllers/application";

import DropdownController from "controllers/dropdown_controller";
application.register("dropdown", DropdownController);

import FlashController from "controllers/flash_controller";
application.register("flash", FlashController);

import RpeSliderController from "controllers/rpe_slider_controller";
application.register("rpe-slider", RpeSliderController);

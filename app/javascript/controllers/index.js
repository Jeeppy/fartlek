import { application } from "controllers/application";

import DropdownController from "controllers/dropdown_controller";
application.register("dropdown", DropdownController);

import FlashController from "controllers/flash_controller";
application.register("flash", FlashController);

import RpeSliderController from "controllers/rpe_slider_controller";
application.register("rpe-slider", RpeSliderController);

import SlideoverController from "controllers/slideover_controller";
application.register("slideover", SlideoverController);

import DurationController from "controllers/duration_controller";
application.register("duration", DurationController);

import LapChartController from "controllers/lap_chart_controller";
application.register("lap-chart", LapChartController);

import CollapsibleController from "controllers/collapsible_controller";
application.register("collapsible", CollapsibleController);

import PaceController from "controllers/pace_controller";
application.register("pace", PaceController);

import TagSelectController from "controllers/tag_select_controller";
application.register("tag-select", TagSelectController);

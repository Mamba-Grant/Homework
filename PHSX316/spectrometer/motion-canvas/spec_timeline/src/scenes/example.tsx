import {makeScene2D, Circle} from '@motion-canvas/2d';
import {all, createRef} from '@motion-canvas/core';

var grid_background_color = "#FFFFFF"
var grid_line_color = "#d8d8d8"
var grid_width = 100
var timeline_events_no = 5
var timeline_events_line_height = 8
var timeline_years_no = 8

export default makeScene2D(function* (view) {
  const myCircle = createRef<Circle>();

  view.add(
    <Circle
      ref={myCircle}
      // try changing these properties:
      x={-300}
      width={140}
      height={140}
      fill="#e13238"
    />,
  );

  yield* all(
    myCircle().position.x(300, 1).to(-300, 1),
    myCircle().fill('#e6a700', 1).to('#e13238', 1),
  );
});


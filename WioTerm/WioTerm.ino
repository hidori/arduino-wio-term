// WioTerm

#include <Arduino.h>
#include <lvgl.h>

#include "Model/Model.h"
#include "Port/SerialPort.h"
#include "View/View.h"

SerialPort serialPort;

Model model;
View view;

void setup() {
}

void loop() {
  model.update();
  view.update(model);
}

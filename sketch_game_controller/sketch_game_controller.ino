void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  int force = analogRead(0);

  int up = digitalRead(7);
  int down = digitalRead(8);
  Serial.print(force);
  Serial.print(",");
  Serial.print(up);
  Serial.print(",");
  Serial.println(down);
  
}

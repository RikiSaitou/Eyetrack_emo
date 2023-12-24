const int qtr0 = A0;
const int qtr1 = A1;

int iniSensorValL, sensorValL;
int iniSensorValR, sensorValR;

int LR =7;
boolean lid = false;
int cnt = 0;
int sensorValues[2]; 

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);

  sensorValues[0] = analogRead(qtr1);
  sensorValues[1] = analogRead(qtr0);

  iniSensorValL = sensorValues[0];
  iniSensorValR = sensorValues[1];
}

void loop() {
  sensorValues[0] = analogRead(qtr1);
  sensorValues[1] = analogRead(qtr0);
  
  sensorValL = sensorValues[0];
  sensorValR = sensorValues[1];
  
  double rasioL = (double)sensorValL / iniSensorValL;
  double rasioR = (double)sensorValR / iniSensorValR;

  //黒目が遠ざかると反射光が増えてセンサ値が減少する
  if(rasioL > 0.985 && rasioR < 0.985){ //右
    for(int i = LR; i < 12; i++){
      delay(40);
      LR = i;
    }
    Serial.println("右");
  }else if(rasioL < 0.985 && rasioR > 0.985){ //左
    for(int i=LR; i>2; i--){
      delay(40);
      LR = i;
    }
    Serial.println("左");
  }else if(lid == false && rasioL < 0.96 && rasioR < 0.96){ //瞬き閉じ動作
    for(int i = 1; i < 9; i++){
      delay(40);
      lid = true;
    }
    Serial.println("瞬き閉じ動作");
  }else if(lid == true && rasioL > 0.96 && rasioR > 0.96){ //瞬き開き動作
    for(int i = 8; i > 0; i--){
      delay(40);
      lid = false;
    }
    Serial.println("瞬き開き動作");
  }else if(lid == false && rasioL > 0.96 && rasioR > 0.96) {   //通常時
    //cnt++;
    //eyelid = 0;
    if(LR <= 7){
      for(int i=LR; i<=7; i++){
        delay(40);
        LR = i;
      }
    }else {
      for(int i=LR; i>=7; i--){
        delay(40);
        LR = i;
      }
    }
    Serial.println("通常時");
  }
  
  //初期値リフレッシュ
  if (cnt > 10){
    iniSensorValL = sensorValL;
    iniSensorValR = sensorValR;
    cnt = 0;
  }
}

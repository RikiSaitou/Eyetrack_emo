/*
閉眼時間を取得(開眼時の時間-閉眼時の時間)
 閉眼時間が150ms以上ならtotalの閉眼時間として足す
 unitTimeごとの 閉眼率 = totalの閉眼時間/一定時間　を計算
 閉眼率が0.1以下なら集中している。
 参考: 3.2節 https://www.jstage.jst.go.jp/article/sicejl/55/3/55_259/_pdf
 シリアル通信のコード参考: https://l-w-i.net/t/arduino/processing_001.txt
*/

import processing.serial.*;
Serial port;
int in_data;
int opened;
int closed;
int closureTime;         // 閉眼時間を格納する変数
int totalClosureTime;     // total閉眼時間
float closureRate;        // 閉眼率
int unitTime = 10000;     // 10秒ごとに数字を更新
int oldTime;
String c = "wait";

// actuation value
int lastTime;  
boolean isTextVisible = true;  
int flashingTime = 300; //flashing interval (millis)
int concentrationValue = 40; //集中度

int fadeDuration = 5000;  // フェードアウト及びフェードインにかける時間（ミリ秒）(5秒使って描画する)
int alphaValueOut = 255;  // フェードアウトするテキストの初期アルファ値（完全に不透明）
int alphaValueIn = 0;  // フェードインするテキストの初期アルファ値（完全に透明）

// integration value
boolean isActuation = false;
int concentrationRate = 0;
int actuationStartTime; 
int actuationDuration = 5000; // これはフェードインアウトするために使用する時間
int concentrationRateThreshouldForActutation = 50;

void setup() {
  size(400, 180);
  frameRate(60);
  //port = new Serial(this, "/dev/ttyACM0", 9600);
  closureTime = 0;
  totalClosureTime = 0;
  oldTime = millis();
  lastTime = millis();  // アクチュエーションのための初期時間を設定
}

void draw() {
  // permanently visible
  background(255);
  fill(0);
  textSize(30);
  text("Concentration level", 50, 50);
  textSize(80);
  text("%", 300, 140);
  
  if (port.available() > 0 ) {
    // シリアルデータ受信
    in_data = port.read();
  }
  
  if (in_data == 0) {
    closed = millis();
  } else if (in_data == 1) {
    opened = millis();
  }
  
  //　集中度の計算処理を開始
  closureTime = opened - closed; //閉眼時間を取得(開眼時の時間-閉眼時の時間)

  if (closureTime > 150) {//閉眼時間が150ms以上ならtotalの閉眼時間として足す
    totalClosureTime += closureTime;
  }
  
  if (millis() - oldTime > unitTime) { // unitTimeごとの 閉眼率 = totalの閉眼時間/一定時間　を計算
    closureRate = (float) totalClosureTime / unitTime;
    oldTime = millis();
    totalClosureTime = 0; //初期化

    //分類3 固定値0%, 25%, 50%, 75%, 100%したもの
    concentrationRate = 0;
    if (closureRate >= 0.10) {
      concentrationRate = 25;
    } else if (closureRate >= 0.08) {
      concentrationRate = 50;
    } else if (closureRate >= 0.05) {
      concentrationRate = 75;
    } else{
      concentrationRate = 100;
    }
    c = Integer.toString(concentrationRate);
    println(concentrationRate);
    
    isActuation = true;
    actuationStartTime = millis();
  }
  
  if(isActuation){
    if (millis() - actuationStartTime > actuationDuration) {
      isActuation = false;
    } else {
      // アクチュエーション継続中の描画処理
      if(concentrationRate > concentrationRateThreshouldForActutation){
        // モーフィング
        int elapsedTime = millis() - actuationStartTime;
        if (elapsedTime < fadeDuration) {// フェードアウトするテキストの透明度を計算
          alphaValueOut = 255 - int(255.0 * elapsedTime / fadeDuration);
        } 
        else {
          alphaValueOut = 0;
        }
        if (elapsedTime < fadeDuration) { // フェードインするテキストの透明度を計算
          alphaValueIn = int(255.0 * elapsedTime / fadeDuration);
        } 
        else {
          alphaValueIn = 255;
        }
        // フェードアウトするテキストを描画
        fill(0, alphaValueOut);
        textSize(90);
        text(str(concentrationRate), 100, 140);
        // フェードインするテキストを描画
        fill(0, alphaValueIn);
        textSize(90);
        text(str(concentrationRate), 100, 140);  // 新たなテキスト位置
      }
      else{
        // フラッシュさせる描画
        if (millis() - lastTime > flashingTime) {
          isTextVisible = !isTextVisible;  // 表示状態を切り替える
          lastTime = millis();  // 最終更新時間をリセット
        }
        if (isTextVisible) {
          fill(0);
          textSize(90);
          text(str(concentrationRate), 100, 140);  
        }
      }
    }
  }
}

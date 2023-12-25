int lastTime;  
boolean isTextVisible = true;  
int flashingTime = 300; //flashing interval (millis)
int concentrationValue = 40; //集中度

int startTime = 10000;  // 開始時間
int fadeDuration = 5000;  // フェードアウト及びフェードインにかける時間（ミリ秒）
int alphaValueOut = 255;  // フェードアウトするテキストの初期アルファ値（完全に不透明）
int alphaValueIn = 0;  // フェードインするテキストの初期アルファ値（完全に透明）

void setup() {
  size(400, 180);  // ウィンドウのサイズを設定
  lastTime = millis();  // 初期時間を設定
}

int thisTime;

void draw() {
  // permanently visible
  background(255);
  fill(0);
  textSize(30);
  text("Concentration level", 50, 50);
  textSize(80);
  text("%", 300, 140);
  if(millis()>10000){
    concentrationValue = 80;
  }
  // -------------------
  if(concentrationValue > 50){
    // モーフィング
    int elapsedTime = millis() - startTime;
    
    // フェードアウトするテキストの透明度を計算
    if (elapsedTime < fadeDuration) {
      alphaValueOut = 255 - int(255.0 * elapsedTime / fadeDuration);
    } 
    else {
      alphaValueOut = 0;
    }
    
    // フェードインするテキストの透明度を計算
    if (elapsedTime < fadeDuration) {
      alphaValueIn = int(255.0 * elapsedTime / fadeDuration);
    } 
    else {
      alphaValueIn = 255;
    }
    
    // フェードアウトするテキストを描画
    fill(0, alphaValueOut);
    textSize(90);
    text("85", 100, 140);
  
    // フェードインするテキストを描画
    fill(0, alphaValueIn);
    textSize(90);
    text("90", 100, 140);  // 新たなテキスト位置
  }
  else{
    // フラッシング
    if (millis() - lastTime > flashingTime) {
      isTextVisible = !isTextVisible;  // 表示状態を切り替える
      lastTime = millis();  // 最終更新時間をリセット
    }
    if (isTextVisible) {
      fill(0);
      textSize(90);
      text("25", 100, 140);  
    }
  }
}

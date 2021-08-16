import org.gicentre.geomap.*;
import controlP5.*;

ControlP5 cp5;
GeoMap geoMap;

Table table, table_ll;
color minColour, maxColour;
color minColour_BDP, maxColour_BDP;

float dataMax;
float dataMax_BDP;
float suicide_rate; 
float suicide_rate_male; 
float suicide_rate_female; 

float BDP_rate; 
int bandStart, bandEnd;
boolean shrinked = false; 
int slide; 
PFont mono;
PFont title;


boolean zenska_prassed; 
String letnica; 
boolean moski; 
boolean zenska; 

PImage button;
PImage buttonFe;
PImage buttonVsi;

int bX , bY;
int bXF, bYF;

boolean grow = true; 

Slider s; 

int diameter = 0;
float opacity;
int suicide_rate_topixel;
int suicide_rate_male_topixel;
int suicide_rate_female_topixel;

int sizeSpeed = 4; 
void setup() {
 
 
 bX = int(width * 0.902);
 bY = int(height * 0.91);
 bXF = int(width * 0.95);
 bYF = int(height * 0.91);

  //silder
  cp5 = new ControlP5(this);
  s = cp5.addSlider("slide")
  .setRange(1987,2014)
  .setValue(2010)
  .setPosition( width * 0.06, height * 0.95)
  .setSize(int(width * 0.25),20)
  .setColorBackground(0xecececec)
  .setColorForeground(0x000000)
  .setColorActive(0x000000)
  .setColorValue(0xecececec)
  ;
  //.setColorLabel(0xffdddddd);
  
  s.setSliderMode(Slider.FLEXIBLE); 

  // branje tabel
  table = loadTable("master.csv", "header");
  table_ll = loadTable("avrage_lla.csv", "header");

  // nastavitev reslulcije
  //fullScreen();
  size(1820,980); 
  //izbira fonta
  mono = createFont("CormorantGaramond-Bold.ttf", 20);
  title = createFont("Cormorant-Bold.ttf", 20);

  //ArchivoBlack-Regular
  //branje zemlejvida
  //geoMap = new GeoMap(300,-height*0.25,width+400 ,height+200,this);
  
  geoMap = new GeoMap(100,-110,width + 20 ,height + 10,this); 
  geoMap.readFile("Europe_min");

  // text za zemljevid
  textAlign(LEFT, BOTTOM);
  textSize(18);
 
  // maximalno število samomorov in BDP v evropskih državah
  dataMax_BDP = 0;
  dataMax = 0;
  for (TableRow row : table.rows()) {
    String country = row.getString("country"); 
      for (int id : geoMap.getFeatures().keySet()) {
        String countryCode = geoMap.getAttributeTable().findRow(str(id),0).getString("NAME"); 
        if (countryCode.equals(country) ==  true) {
          float trenutna_vrednost = row.getFloat(10);
          dataMax_BDP = max(dataMax_BDP, trenutna_vrednost);
          dataMax = max(dataMax, row.getFloat(6));
         } 
      }
  }
  minColour_BDP = color(222, 235, 247);   // Light blue
  maxColour_BDP = color(49, 130, 189);    // Dark blue.
  
  
  moski = false; 
  button = loadImage("male.png");
  button.resize(int(height * 0.09),int(height * 0.09));
 
 
   zenska = false; 
  buttonFe = loadImage("female.png");
 buttonFe.resize(int(height * 0.09),int(height * 0.09));
}
 
void draw()
{

  background(255, 255, 255);  // Ocean colour
  noStroke(); 

  fill(255); 
  //stroke(0);
  //rect(0, height - 95, width,95); 
  fill(0);
  textSize(30);
  
  //text("1987", 30,height - 20);
  //text("2014", 630,height - 20);
  
  text("GDP",  width*0.62 ,height* 0.975);
  setGradient(int(width*0.69), int(height * 0.95), 250, 20, minColour_BDP, maxColour_BDP);
  text("0",  width*0.67 ,height* 0.975);
  text("126 000", width*0.84, height* 0.975);

  
  textSize(20);
  stroke(0, 40);              // Boundary colour

 
  // Draw entire world map.
  fill(255, 255, 255);        // Land colour
  geoMap.draw();              // Draw the entire map.

  // Izris držav odvisno od BDP 
  for (int id : geoMap.getFeatures().keySet()) {
    String countryCode = geoMap.getAttributeTable().findRow(str(id),0).getString("NAME");    
    fill (255);
    for (TableRow dataRow : table.findRows(letnica, 1)) {
      if (countryCode.equals(dataRow.getString("country"))) {
        String BDP_string = dataRow.getString(10);
        BDP_rate = float(BDP_string);
        float BDP_norm = BDP_rate / dataMax_BDP;
        //println(letnica, countryCode, BDP_string, BDP_rate, "max: ", dataMax_BDP,BDP_norm );    
        fill(lerpColor(minColour_BDP, maxColour_BDP, BDP_norm));
        }
    }
   geoMap.draw(id);
  }
  
  // Izris krogov, ki ponazarjajo relativno število samomorov
  for (int id : geoMap.getFeatures().keySet()) {
    String countryCode = geoMap.getAttributeTable().findRow(str(id),0).getString("NAME");    
    TableRow dataRowLL = table_ll.findRow(countryCode, 1);   
    float sucide_rate_sum = 0; 
    int stevilo_primerov = 0; 
    //moski
    int stevilo_primerov_male= 0; 
    float sucide_rate_sum_male= 0; 
    
    //zenske
    int stevilo_primerov_female= 0; 
    float sucide_rate_sum_female= 0; 



    for (TableRow dataRow : table.findRows(letnica, 1)) {
       if (countryCode.equals(dataRow.getString("country"))) {
          float suicide_rate = dataRow.getFloat(6);
          sucide_rate_sum = sucide_rate_sum + suicide_rate;
          stevilo_primerov++; 
 
          if ("male".equals(dataRow.getString("sex"))) {
            float suicide_rate_male = dataRow.getFloat(6);
            stevilo_primerov_male++; 
            sucide_rate_sum_male = sucide_rate_sum_male + suicide_rate_male;
            
          }
          
          
          if ("female".equals(dataRow.getString("sex"))) {
            float suicide_rate_female = dataRow.getFloat(6);
            stevilo_primerov_female++; 
            sucide_rate_sum_female = sucide_rate_sum_female + suicide_rate_female; 
          }
          
          
          
       }
    }
      
     //skupno
     float suicide_rate_avg = sucide_rate_sum / stevilo_primerov; 
     suicide_rate = suicide_rate_avg / dataMax;
     //moski
     float suicide_rate_male = sucide_rate_sum_male / stevilo_primerov_male; 
     suicide_rate_male = suicide_rate_male / dataMax;
     
     //zenske
     float suicide_rate_female = sucide_rate_sum_female / stevilo_primerov_female; 
     suicide_rate_female = suicide_rate_female / dataMax;
     
    if (dataRowLL != null) {
      float coordinates_geoY = dataRowLL.getFloat(2);
      float coordinates_geoX = dataRowLL.getFloat(3);
      // println ( countryCode, coordinates_geoX,coordinates_geoY);
      PVector coordinates = geoMap.geoToScreen(coordinates_geoX, coordinates_geoY); 
      
     
      
      suicide_rate_topixel = int(suicide_rate * 300);
      suicide_rate_male_topixel = int(suicide_rate_male * 300);  
      suicide_rate_female_topixel = int(suicide_rate_female * 300);  
      //println(countryCode, "suicide rate", suicide_rate_avg, "skaliran", suicide_rate * 300); 
      

     fill(0);         
    if (!zenska && !moski) {
        ellipse(coordinates.x, coordinates.y, suicide_rate_topixel , suicide_rate_topixel);
    }
    else {       
     int current_value = suicide_rate_topixel + diameter; 
     if(moski) {     
         if (current_value >= suicide_rate_male_topixel)  {
             current_value = suicide_rate_male_topixel;
          }
     }
      if(zenska) {       
        if (current_value <= suicide_rate_female_topixel)  {
           current_value = suicide_rate_female_topixel;
            }
     }
        ellipse(coordinates.x, coordinates.y, current_value , current_value );
    }
  }
  
  }
  if (moski) {
  
  diameter += sizeSpeed; }
  if (zenska) {
      diameter -= sizeSpeed; }

  
  
  int id = geoMap.getID(mouseX, mouseY);
  if (id != -1) {
    boolean obstaja = false; 
    fill(0, 100);
    stroke(0, 0, 0);
    geoMap.draw(id);
    
    String BDP_rate_izris = ""; 
    float sucide_rate_sum = 0; 
    int stevilo_primerov = 0; 
    
    String name = geoMap.getAttributeTable().findRow(str(id),0).getString("NAME");    
    //moski
    int stevilo_primerov_male= 0; 
    float sucide_rate_sum_male= 0; 
    
    //zenske
    int stevilo_primerov_female= 0; 
    float sucide_rate_sum_female= 0; 

    for (TableRow dataRow : table.findRows(letnica, 1)) {
      if (name.equals(dataRow.getString("country"))) {
        obstaja = true; 
        float suicide_rate = dataRow.getFloat(6);
        sucide_rate_sum = sucide_rate_sum + suicide_rate;
        stevilo_primerov++; 
        if ("male".equals(dataRow.getString("sex"))) {
            float suicide_rate_male = dataRow.getFloat(6);
            stevilo_primerov_male++; 
            sucide_rate_sum_male = sucide_rate_sum_male + suicide_rate_male;
          }
          if ("female".equals(dataRow.getString("sex"))) {
            float suicide_rate_female = dataRow.getFloat(6);
            stevilo_primerov_female++; 
            sucide_rate_sum_female = sucide_rate_sum_female + suicide_rate_female; 
          }
          
        //BDP
         BDP_rate_izris = dataRow.getString(10);
        
        
        //println(letnica, countryCode, BDP_string, BDP_rate, "max: ", dataMax_BDP,BDP_norm );    
       }
    }
    
     //moski
    float suicide_rate_male = sucide_rate_sum_male / stevilo_primerov_male; 
     
         //zenske
    float suicide_rate_female = sucide_rate_sum_female / stevilo_primerov_female; 
    
    float suicide_rate_avg = sucide_rate_sum / stevilo_primerov; 
    
   // print (stevilo_primerov) ;
    fill(200, 200, 200);
    fill(255, 200);
    rect(mouseX + 10 , mouseY + 10, 310, 100);
    fill(0); 
    textSize(25); 
    text(name, mouseX+ 30, mouseY+50);
    //println (suicide_rate_avg); 
     textSize(18); 
    if (obstaja) {
    if (moski) {
      text(str(int(suicide_rate_male)) + " male suicides per 100,000 people " , mouseX+ 30, mouseY+80);
    }
    
    if (zenska) text(str(int(suicide_rate_female)) + " female suicides per 100,000 people " , mouseX+ 30, mouseY+80);

    if (!zenska && !moski) text(str(int(suicide_rate_avg)) + " suicides per 100,000 people " , mouseX+ 30, mouseY+80);
    
    String BDP_besedilo= "GDP: "  + BDP_rate_izris;  
    text(BDP_besedilo , mouseX+ 30, mouseY+100);
    //println(dataMax_BDP);
    }
    else {
      text ( "podatki ne obstajajo" , mouseX+ 30, mouseY+80);
    }
    
}
    // naslov
    fill(0);
    textFont(title);
    textSize(70);
    text("RISK OF SUICIDE", 45, height*0.1); 
    
    //podnaslov
    textFont(mono);
    textSize(27);
    fill(100);
    String naslov = "How economic and social factors affect \nEuropean suicide rates in year " + letnica + "?";
    text(naslov, 50, height*0.1 + 70); 
    
    // kvadratek
    fill (100, 50); 
    if (moski) rect (bX , bY , int(height * 0.09), int(height * 0.09)); 
    if (zenska) rect (bXF , bYF ,int(height * 0.09), int(height * 0.09)); 
    
    //sliki za spol
    image(button, bX, bY);
    image(buttonFe, bXF, bYF);
    //razdelki
    
    fill(0); 
    stroke (200, 200, 200);
    line(0, height * 0.91, width, height * 0.91);
    
    
   
    //year/rate
    line(width*0.34, height * 0.91, width*0.34, height);
    //
    line(width*0.61, height * 0.91, width*0.61, height);
    
    line(width*0.95, height * 0.91, width*0.95, height);
    line(width*0.902, height * 0.91, width*0.902, height);

    
    //year
    text ("year", width*0.02, height * 0.975) ;

   
    //letnica ! deli z //0.592
    text(letnica, s.getValuePosition() + width*0.05, height * 0.95);
    fill (0); 
    
    textLeading(25);
    text ("suicide rate", width*0.36, height * 0.975) ;

    ellipse (width*0.45, height * 0.96,  10/0.592, 10/0.592); // 10
    text ("10", width*0.45 + 15, height * 0.975) ;
    
    ellipse (width*0.49, height * 0.96,  25/0.592, 25/0.592); // 30
    text ("25", width*0.49 + 30, height * 0.975) ;

    ellipse (width*0.55, height * 0.96,  40/0.592, 40/0.592); //50
    text ("40", width*0.55 + 50, height * 0.975) ;


   // print(dataMax); 


 
}
void controlEvent(ControlEvent theEvent) {
   if(theEvent.isController()) { 
     float slider_value_float = theEvent.getController().getValue();
     int letnica_int = int(slider_value_float);    
     letnica = str (letnica_int);
  }
}

void setGradient(int x, int y, float w, float h, color c1, color c2) {
  noFill();
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
}


void mouseClicked(){
  if( mouseX > bX && mouseX < (bX + button.width) &&
      mouseY > bY && mouseY < (bY + button.height)){
       // print("pressed");
        diameter = 0; 
       // print(moski); 
        zenska = false;         
        if (!moski) moski = true; 
        else moski = false; 
      };
       if( mouseX > bXF && mouseX < (bXF + buttonFe.width) &&
           mouseY > bYF && mouseY < (bYF + buttonFe.height)){
         // println("pressed and no");
          diameter = 0; 
          moski = false; 
          if (!zenska) zenska = true; 
          else zenska = false; 
      };
}
    
    

 

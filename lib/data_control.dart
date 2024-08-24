

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseflutter/dashboard.dart';
import 'package:firebaseflutter/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'main.dart';

class DataControl extends StatefulWidget{
 
  const DataControl({super.key});

  @override
  State<StatefulWidget> createState() => _DataControlState();
  
  }
  

class _DataControlState extends State<DataControl> {
  bool isLoading= false;
  bool isEmpty=false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final databaseReference = FirebaseDatabase.instance.ref();

   List<dynamic>? registros;
   List<ExpansionRegistro>? listRegistros;
   late List<ExpansionFechas> fechasReg;
   late List<String> horasReg;
   
   int i=0;
   int datacount =100;
@override
  void initState(){
    super.initState();
    
    _getRegistros();   
    }

  @override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: const Center(  child: Text('Calidad del Aire',textAlign: TextAlign.justify,style: TextStyle(fontStyle: FontStyle.italic,fontSize: 30,fontWeight: FontWeight.bold),)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             const DrawerHeader(
              decoration: BoxDecoration(color:Colors.blueGrey),
              child: Text(
                'Menu',
                style:TextStyle(color:Colors.white, fontSize: 19),
              ),
              ),
              ListTile(
              leading:  const Icon(Icons.home),
              title:  const Text('Inicio'),
              selectedColor: Colors.blueGrey,
              onTap: _handleHome,
              ),
              ListTile(
              leading:  const Icon(Icons.history),
              title:  const Text('Registro'),
              selectedColor: Colors.blueGrey,
              onTap: _handleRegistro,
              ),
               ListTile(
              leading:  const Icon(Icons.logout_sharp),
              title:  const Text('Cerrar Sesión'),
              selectedColor: Colors.blueGrey,
              onTap: _handleLoginOutPopUp,
            ),
          ],
        ),
          ),
      body:Center(child: isLoading?ListView(
                              
                              children: [
                                  !isEmpty?ExpansionPanelList(
                                    
                                    dividerColor: Colors.grey,
                                    expandIconColor: Colors.white,
                              expansionCallback: (int index, isExpanded) {
                                setState(() {
                                  
                                   fechasReg[index].isExpanded =!fechasReg[index].isExpanded;
                                  
                                  
                                });
                              },
                              children: fechasReg.map((ExpansionFechas item) {   // FechasReg debe ser una sola por fecha formato 21-09-01
                                return ExpansionPanel(
                                  backgroundColor: Colors.black,

                                  headerBuilder: (BuildContext context, bool isExpanded){
                                            return tituloRegis(item,_screenRotate());
                                  },
                                 isExpanded: item.isExpanded,
                                 
                                  body: cuerpoRegis(item,listRegistros!.where((ExpansionRegistro e) => e.fecha==item.fecha).toList()),
                                   );
                              }
                            ).toList(), ):const Text('Por el momento no hay Registro'),
                            ],
                            ):const Center(child:CircularProgressIndicator(strokeCap: StrokeCap.round,strokeWidth: 5,color: Colors.blue,))
                            )
                            );




   
    
   }
Widget tituloRegis(ExpansionFechas item,bool rotate){
  return TextButton(
    style: TextButton.styleFrom(
              textStyle: const TextStyle(
                height: 2,
                fontFamily: 'Arial',
                fontSize: 20,
                color: Color.fromARGB(255, 2, 138, 250),
                fontWeight: FontWeight.w500,
              ),
           ),
    onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder: (context)=> DataGrap(listRegistros:listRegistros,))),//Navigator.pop(context),

    child: Text(item.fecha,style: const TextStyle(color: Colors.white),));//Text(item.fecha ,style: const TextStyle(fontSize: 20),);
  }
Widget cuerpoRegis(ExpansionFechas item,List<ExpansionRegistro> sublist){
  Widget dataBox(String mag,String unidad,double item){
    return Container(
      height: 50,
      decoration:  BoxDecoration(border:Border.all(color: Colors.white,style: BorderStyle.solid,width: 0.7), color: Colors.black),
      child:Center(child: Text('$mag \n  $item $unidad',textAlign:TextAlign.center,style: const TextStyle(color:Colors.white),)));

  }
  return  
                             ExpansionPanelList(
                              dividerColor: const Color.fromARGB(255, 190, 177, 177),
                              expandIconColor: Colors.white,
                              expansionCallback: (int index, isExpanded) {
                                setState(() {
                                  
                                   sublist[index].isExpanded =!sublist[index].isExpanded;
                                  
                                  
                                });
                              },
                              children: sublist.map((ExpansionRegistro item) {
                                return ExpansionPanel(
                                  backgroundColor: Colors.black,
                                  headerBuilder: (BuildContext context, bool isExpanded){
                                            return Padding(padding:const  EdgeInsets.only(top:15,bottom: 0,left: 7),child:Text(item.hora, textAlign: TextAlign.start,style: const TextStyle(color: Colors.white,fontSize: 20),)); // falta poner estilos
                                  },
                                 isExpanded: item.isExpanded,
                                  body: Column(                        
                                  
                                   
                                    children: [
                                   
                                      Row(
                                      children: [
                                          Expanded(child:dataBox('Temperatura', '°C', item.temp),),                                        
                                          Expanded(child:dataBox('Humedad', '%', item.hum),)
                                    ],),
                                    
                                   
                                    Row(
                                      children: [
                                        Expanded(child: dataBox('Monoxido de carbono','ppm', item.co),),
                                        Expanded(child:dataBox('Dioxido de carbono', 'ppm', item.co2),),
                                    ],),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(child: dataBox('PM 10','ppm', item.pm_10),),
                                        Expanded(child: dataBox('PM 2.5','ppm', item.pm_25),),
                                    ],),                                    
                                    Row(
                                      children: [
                                        Expanded(child: dataBox('Formaldehido','ppm', item.hcho))
                                    //const Spacer()
                                    ],),

                                  ],),
                                   );
                              }
                            ).toList(),
                            );
                           
}
  bool _createListTimes(){
    if(registros!=null){ // Agrego el primer registro para inicializar la lista
      registros?.sort((a,b)=>a['TimeStamp'] - b['TimeStamp']);   // ordeno la lista por tiempos
      ExpansionRegistro first= ExpansionRegistro(                                        
                                        hour: DateTime.fromMillisecondsSinceEpoch(registros?.first['TimeStamp'] * 1000, isUtc: false),
                                        hora:timeFormatTime(registros?.first['TimeStamp']),
                                        fecha:timeFormatDate(registros?.first['TimeStamp']),
                                        co:1.0*registros?.first['CO'],
                                        temp:1.0*registros?.first['Temperatura'],
                                        hum:1.0*registros?.first['Humedad'],
                                        pm_10:1.0*registros?.first['PM_1'],
                                        pm_25:1.0*registros?.first['PM2_5'],
                                        hcho:1.0*registros?.first['HCHO'],
                                        co2:1.0*registros?.first['CO2'],);
    listRegistros =[first];
    fechasReg = [ExpansionFechas(fecha:first.fecha)];
    registros?.forEach((dynamic element) {
      if(element!=registros?.first){  // agrego cada registro a la lista
        try{        
          ExpansionRegistro item = ExpansionRegistro(      
                                        hour: DateTime.fromMillisecondsSinceEpoch(element['TimeStamp'] * 1000, isUtc: false),                           
                                        hora:timeFormatTime(element['TimeStamp']),
                                        fecha:timeFormatDate(element['TimeStamp']),
                                        co:1.0*element['CO'],
                                        temp:1.0*element['Temperatura'],
                                        hum:1.0*element['Humedad'],
                                        pm_10:1.0*element['PM_1'],
                                        pm_25:1.0*element['PM2_5'],
                                        hcho:1.0*element['HCHO'],
                                        co2:1.0*element['CO2'],
                                        );
          listRegistros?.add(item);
          bool exists = false;
          for(int i=0; i<fechasReg.length;i++){  // Agrego las diferentes fechas a la lista.
            if(fechasReg[i].fecha.compareTo(item.fecha)==0){
              exists = true;
            }
          }
          if(!exists) {fechasReg.add(ExpansionFechas(fecha: item.fecha));}
          }catch(e){
     // print('Error al agregar registro a la lista: $e');
        }
    }
  });
  return false;
    }else{return true;}

  }
  _getRegistros() async{
    DatabaseEvent event = await  databaseReference.child('Registros').once();
    if(event.snapshot.exists){
      registros = event.snapshot.value as List?;
      setState(() { });
      isEmpty = _createListTimes();
      isLoading=true;
    }
  }
  bool _screenRotate(){
        return (MediaQuery.of(context).orientation == Orientation.portrait);
    }
  _handleHome(){
    //Navigator.of(context).pushReplacement(  
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const Dashboard()));
    }
  _handleRegistro(){
    Navigator.pop(context);
    
    /*  Alert(
        context: context,
        type:AlertType.warning,
        title:'Registro historico',
        desc: 'Pagina en construccion, FECHA ${dateTime(data)}',
        buttons: [DialogButton(
        onPressed:()=>Navigator.pop(context),
          width: 120,
          child: const Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )]
        ).show();*/
    }
  _handleLoginOutPopUp(){
    Alert(
      context: context,
      type: AlertType.info,
      title: "Login Out",
      desc: "Usted está por cerrar sesión",
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          width: 120,
          child: const Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        DialogButton(
          onPressed: _handleSignOut,
          width: 120,
          child: const Text(
            "Si",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        )
      ],
    ).show();
  }
  Future<Null> _handleSignOut() async{
    setState(() {
      isLoading = true;
    });
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    setState(() {
      isLoading = false;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> const MyApp()), (Route<dynamic> route) => false);
    });
    
 
     
    
  }


}

String timeFormatDate(int timestamp){           
    return DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: false)); 
  }
String timeFormatTime(int timestamp){   
    return DateFormat('HH:mm').format(DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: false));     
  }
class ExpansionItem{
  bool isExpanded;
  final String magnitud;
  final double currval;
  final String unidad;
  final double maxvalue;
  ExpansionItem({this.isExpanded=false,required this.magnitud,required this.currval,required this.unidad, required this.maxvalue,});
}
class ExpansionRegistro{
  bool isExpanded;
  final double temp;
  final double hum;
  final double pm_10;
  final double pm_25;
  final double hcho;
  final double co;
  final double co2;
   DateTime hour;
   String fecha;
   String hora;

  ExpansionRegistro({required this.hour,required this.fecha, required this.hora,this.isExpanded=false,required this.co,required this.temp, required this.hum, required this.pm_10, required this.pm_25, required this.hcho, required this.co2,}); 
  }
class ExpansionFechas{
  bool isExpanded;
  final String fecha;
  ExpansionFechas({required this.fecha,this.isExpanded=false});
}
Widget tituloItem(ExpansionItem item,bool rotate){
  Icon iconState = const Icon(Icons.abc,size: 0,);
  double status = item.currval/item.maxvalue;
  if(status>0.4 && status<0.6){ 
    iconState = const Icon(Icons.info_outlined,size: 30,color: Colors.blue,);
  }else if(status>=0.6 && status<=0.8){
    iconState = const Icon(Icons.warning_amber_outlined,size: 30,color: Colors.amber,);
  }else if(status>0.8){
    iconState = const Icon(Icons.dangerous_rounded,size:30,color:Colors.red,);
    
  }

  return  Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ 
                  Text(item.magnitud ,style: const TextStyle(fontSize: 20),),
                  const Spacer(),
                  Container(padding: const EdgeInsets.only(right:5,bottom: 5),child: iconState),
                  Text('${item.currval} ${item.unidad}',style: const TextStyle(fontSize: 15),),
                  ]
               );
}
Widget cuerpoItem(ExpansionItem item){
String path = 'assets/images/Status1.png';
double status = item.currval/item.maxvalue;
  if(status<0.2){
    path = 'assets/images/Status1.png';
  }else if(status>0.2 && status<0.4){
    path = 'assets/images/Status2.png';
  }else if(status>0.4 && status<0.6){ 
    path = 'assets/images/Status3.png';
  }else if(status>0.6 && status<0.8){
    path = 'assets/images/Status4.png';
  }else if(status>0.8){
    path = 'assets/images/Status5.png';
  }
  return  Row( 
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children:<Widget> [
                                    Column(                                      
                                      children: [
                                      const Text('Estado:', textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
                                       Image.asset(path,fit: BoxFit.contain,scale:3),
                                    ],),                                    
                                     const Spacer(flex: 2,),
                                      Text(
                                          '${item.currval}',
                                          style: const TextStyle(
                                                  fontSize: 50, fontWeight: FontWeight.bold),
                                      ),
                                       Text(
                                        item.unidad, 
                                        style: const TextStyle(
                                          fontSize: 50, fontWeight: FontWeight.bold),
                                      ),
                                       const Spacer(flex:2),
                                      Column(                                      
                                      children: [
                                      const Text('Nivel critico:', textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
                                           Text('${item.maxvalue} ${item.unidad}',style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ],), 
                                    ],
                            );
}

class DataGrap  extends StatelessWidget{
  final List<ExpansionRegistro>? listRegistros;
const DataGrap({super.key,required this.listRegistros});
      
   //Map<dynamic,dynamic> regCO = {listRegistros.first.hora:listRegistros.first.co};
   
  @override
  Widget build(BuildContext context) {
    return PopScope(child:SingleChildScrollView(
      child:SafeArea( child:Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [   
        _createGraph(0),
        _createGraph(1),
        _createGraph(2),
        _createGraph(3),
        _createGraph(4),
        _createGraph(5),
        _createGraph(6),
    ]
    )))
   );
    
  }

Widget _createGraph(int index){ // Cambiar maxvalues.
  String text ="";
  String unidad="";
  double maxvalue= 0;
  switch (index) {
      case 0:
      text = 'Temperatura';
      unidad = '°C';
      maxvalue = 80;
      break;                                        
      case 1:
      text = 'Humedad';
      unidad = '%';
      maxvalue = 120;
      break;                                                                                
      case 2:         
      text = 'Monoxido de Carbono';
      unidad = 'ppm';
      maxvalue = 5000;
      break;                                                                       
      case 3: 
      text = 'Dioxido de Carbono';
      unidad = 'ppm';
      maxvalue = 5000;
      break;                                                                    
      case 4:         
      text = 'Particulas PM 10';
      unidad = 'ug/m3';
      maxvalue = 2000;
      break;
      case 5:         
      text = 'Particulas PM 2.5';
      unidad = 'ug/m3';
      maxvalue = 2000;
      break;                                                                 
    default:         
      text = 'Formaldehido';
      unidad = 'ppm';
      maxvalue = 2000;
      break;
  }
  return SfCartesianChart(
      onTooltipRender: ((tooltipArgs) =>tooltipArgs.text= '${tooltipArgs.text} $unidad'),
      zoomPanBehavior: ZoomPanBehavior(enablePinching: true,),
      primaryXAxis: DateTimeAxis(majorGridLines: MajorGridLines(color: Colors.grey[400],width: 0.7,dashArray: const [1,2,3,4]),interval: 5,labelStyle: const TextStyle(color: Colors.white)),
      title: ChartTitle(alignment: ChartAlignment.center,text: text,textStyle: const TextStyle(
                fontFamily: 'Arial',
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w500,)),
      primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(color: Colors.grey[400],width: 0.7,dashArray: const [1,2,3,4]),
          labelStyle:const TextStyle(color: Colors.white) ,
          title: AxisTitle(text: unidad,alignment: ChartAlignment.center,textStyle:const TextStyle(color:Colors.white)),
          maximum: maxvalue,
          ),
          
      plotAreaBorderWidth: 0,
      tooltipBehavior: TooltipBehavior(enable: true),
      series:<CartesianSeries>[
        AreaSeries<ExpansionRegistro,DateTime>(
          color: Colors.grey[400],
          enableTooltip: true,
          name: text, 
          opacity: 0.3,
          borderWidth: 2,
          borderColor: Colors.blueGrey[600],
          dataSource: listRegistros!,
          xValueMapper: (ExpansionRegistro item, _)=> item.hour,
          yValueMapper: (ExpansionRegistro item, _){
                            switch (index) {
                                        case 0:
                                        return item.temp;                                        
                                        case 1:
                                        return item.hum;                                                                                
                                        case 2:         
                                        return item.co;                                                                       
                                        case 3: 
                                        return item.co2;                                                                    
                                        case 4:         
                                        return item.pm_10;                                                                  
                                        case 5:
                                        return item.pm_25;
                                        default:
                                        return item.hcho;
                                    }
                                  } ,
          ),
      ]
     );
}
}

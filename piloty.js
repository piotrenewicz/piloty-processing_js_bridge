var usb = require('usb');
fs = require('fs');
usb.setDebugLevel(0);
var myUsb = usb.findByIds(312, 312);
var i = 0;
if (!myUsb)
	return console.log('No device found!');
else {
	myUsb.open();
	myUsb.interface().claim();
	poll(myUsb, i);
}

function poll(device, counter) {
	//pętla na bieżąco sprawdza czy jest coś do odebrania z pilotów.	
	counter++;	
	//console.log("\n\n["+counter+"] Waiting for a poll. . .")
	device.interface().endpoint(129).transfer(64,function(err,data) {
		if (err) return console.error(err);
		data = data.toString('hex');
		if(data.slice(0,12) == "032800000000") {
			//console.log("~~ IGNORING THIS LINE!")
		}
		else {
			parseData(data); // data odebrana, wysyłanie do obróbki
		}
		poll(device, counter); // brak danych, poll again.
	});
}

function parseData(data) { // obróbka danych
	var encryptionData = { // słownik kodów usb : przyciski na pilocie, które to wysyłają
		"0c": "0",
		"02": "1",
		"09": "2",
		"0e": "3",
		"03": "4",
		"0a": "5",
		"0f": "6",
		"04": "7",
		"0b": "8",
		"10": "9",
		"05": "/",
		"11": ".",
		"06": "-"
	};
	var pilot = {
		Header: data.slice(0,8),
		Id: undefined
	};
	data = data.slice(8);
	data = data.match(/.{1,2}/g);
	data = data.filter(function(item) {
		return item !== "00";
	});
	pilot.Id = data.shift() + data.shift();
	// console.log("Header: "+pilot.Header);
	// console.log("ID: "+pilot.Id);
	// console.log(data);
	var translatedData = [];
	for(var key in encryptionData) {
		for(var i=0; i<data.length; i++) {
			if(key === data[i])
				translatedData[i] = encryptionData[key];
		}
	}
	if(translatedData.length !== 0 && pilot.Header === "03280000") {
		// pilot do głosowania.
		var dataReadyToSend = pilot.Id+";"+translatedData.join('');
		
		//PONIZSZA LINIA ODPOWIADA ZA WYSYLANIE ID PILOTA I KODU DO Processing
		passBy(dataReadyToSend);
		 
	}
	if(pilot.Header === "01148000" && data.join('') === "03") { 
		// pilot master, nie oskryptowany !!!
		var dataReadyToSend = data.join('');
		

		//~~~~~~
		//PONIZSZA LINIA ODPOWIADALA ZA WYSYLANIE ID PILOTA I KODU DO KODU HTML
		//TO JEST KOD Z PILOTA NAUCZYCIELA
		//~~~~~~
		//io.emit("emitTranslatedCode", pilot.Id, data.join(''));
	}
	/*commenting out comments. depreceated.	
		// console.log(data.join(''));
		// var codeKappa = data.join('');
		// if(codeKappa=="2006" || codeKappa=='2005') {
		// 	io.emit("kappa", codeKappa);
	
		// }
		//wypierdzielac z tym szajsem ponizej
		//var mouse = require("./mouse.js");
		//mouse(1,5,data);
	*/
}

function passBy(send){
	// moja funkcja zarządza protokołem w stylu push-pull na fs żeby przepchać dane do processing
	// znak "//" w fs = /temp/data.txt oznacza gotowość na przepchnięcie kolejnego kodu.
	// w razie gdy nie ma znaku "//" próbujemy ponownie aż processing zgłosi gotowość.
	// blokuje to reszte silnika przed działaniem, więc uzyskuję synchronizacje thread.
	// (nie ma nigdzie multi-threadingu, to są osobne programy ale działają wspólnie więc muszą sie syncować )
	fs.readFile('temp/data.txt', function (err1,data){
		if(!err1){
			// console.log(data.toString());
			if(data.toString().trim() === '//' ){
				console.log(send)
				fs.writeFile('temp/data.txt', send, function (err2) {
					if (err2)console.log(err2);
				});
			}else{
				passBy(send);
			}
		}else{
			console.log(err1);
		}
	});
}

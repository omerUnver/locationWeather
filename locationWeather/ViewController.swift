//
//  ViewController.swift
//  locationWeather
//
//  Created by M.Ömer Ünver on 19.10.2022.
//

import UIKit
import CoreLocation
//Kullanıcının konumunu almak için coreLocation kütüphanesini import ettim ardından konum almak için gerekli işlemleri gerçekleştirdim
class ViewController: UIViewController, CLLocationManagerDelegate{
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var maxTemp: UILabel!
    @IBOutlet weak var minTemp: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var sicaklik: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var feelsLike: UILabel!
    var locationManager = CLLocationManager()
    var latitude = Double()
    var longitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            locationSetup()
    }
    func locationSetup(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //Kullanıcının konumunu en doğru şekilde aldım
        locationManager.requestWhenInUseAuthorization() //Kullanıcıya konumunu kullanacağımı belirttim
        locationManager.startUpdatingLocation() //Kullanıcının konum güncellemesini başlattım
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        print(latitude)
        print(longitude)
        let url = URLRequest(url: URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=0cf0b8aec57f0673aa317cfae9353996&lang=tr&units=metric")!) //Kullanıcıdan aldığım latitude ve longitude değerlerini api'nin istediği latitude ve longitude değerlerinin yerlerine yazdım böylelikle kullanıcının konumu geldiğinde api'da alınan konum değerlerine göre bir obje vericek
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.alertFunc(title: "Error!", message: error?.localizedDescription ?? "Error!")
                }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!) as! [String : Any]
                        if let locationName = json["name"] as? String{ //Api'dan konum ismini aldım
                            DispatchQueue.main.async {
                                self.locationName.text = locationName
                            }
                        }
                        if let main = json["main"] as? [String : Any] { //Api'dan sıcaklık değerlerini aldım
                                if let temp = main["temp"] as? Double, let minTemp = main["temp_min"] as? Double, let maxTemp = main["temp_max"] as? Double, let feelsLike = main["feels_like"] as? Double{
                                    DispatchQueue.main.async {
                                        self.sicaklik.text = "\(temp) C°"
                                        self.minTemp.text = "Min: \(minTemp) C°"
                                        self.maxTemp.text = "Max: \(maxTemp) C°"
                                        self.feelsLike.text = "Hissedilen Sıcaklık: \(feelsLike) C°"
                                    }
                                }
                        }
                        if let weatherIcon = json["weather"] as? [[String : Any]] { //Api'den icon'u aldım
                            for weatIcon in weatherIcon{
                                if let icon = weatIcon["icon"] as? String, let description = weatIcon["description"] as? String {
                                    DispatchQueue.main.async {
                                        self.iconImage.image = UIImage(named: icon)
                                        self.descriptionLabel.text = "Hava \(description)"
                                    }
                                }
                            }
                        }
                    } catch {
                        self.alertFunc(title: "Error!!", message: error.localizedDescription)
                    }
            }
            task.resume()
            self.locationManager.stopUpdatingLocation() //Tüm işlemler bittiğinde uygulamanın kullanıcının konum almasını durdurdum
        }
    }
    func alertFunc(title : String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}


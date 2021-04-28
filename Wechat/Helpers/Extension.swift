import Foundation
import UIKit

extension UIView{
    public var width :CGFloat {
        return self.frame.size.width
    }
    public var height : CGFloat {
        return self.frame.size.height
    }
    public var top : CGFloat {
        return self.frame.origin.y
    }
    public var bottom : CGFloat {
        return self.frame.origin.y + self.frame.size.height
    }
    public var left : CGFloat {
        return self.frame.origin.x
    }
    public var right : CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}

extension Date{
    func longDate()->String{
        let  dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter.string(from: self)
    }
    func  stringDate()->String{
        let  dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMMyyyyHHmmss"
        return dateFormatter.string(from: self)
    }
    func interval(ofComponent comp: Calendar.Component,fromDate date:Date)->Int{
        let currentCalendar = Calendar.current
        guard  let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else {
            return 0
        }
        return start - end
    }
}
extension UIImage{
    var isPortrait:Bool{return size.height > size.width}
    var isLandscape:Bool{return size.width > size.height}
    var breadth:CGFloat{return min(size.width, size.height)}
    var breathSize: CGSize{return CGSize(width: breadth, height: breadth)}
    var breathRect: CGRect{return CGRect(origin: .zero, size: breathSize)}
    
    var circleMasked:UIImage? {
        UIGraphicsBeginImageContextWithOptions(breathSize, false, scale)
        defer{UIGraphicsEndImageContext()}
        guard let cgImage = cgImage?.cropping(to: CGRect(origin:CGPoint(x: isLandscape ? floor((size.width - size.height)/2):0, y: isPortrait ? floor((size.height - size.width)/2):0), size: breathSize)) else {
            return nil
        }
        UIBezierPath(ovalIn: breathRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breathRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


extension UIColor {
    static var sampleRed = UIColor(red: 252/255, green: 70/255, blue: 93/255, alpha: 1)
    static var sampleGreen = UIColor(red: 49/255, green: 193/255, blue: 109/255, alpha: 1)
    static var sampleBlue = UIColor(red: 52/255, green: 154/255, blue: 254/255, alpha: 1)
}

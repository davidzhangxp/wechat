//
//  EditMomentViewController.swift
//  Wechat
//
//  Created by Max Wen on 1/2/21.
//

import UIKit

class EditMomentViewController: UIViewController {
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Moment"
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.clipsToBounds = true
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
  
        
        // Do any additional setup after loading the view.
    }
    static func createLayout()-> UICollectionViewCompositionalLayout{
        //Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        let verticalStackItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.5)))
        verticalStackItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        //group
        
        let verticalStackGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1)), subitem: verticalStackItem, count: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(3/5)),
                                                       subitems: [
        item,
        verticalStackGroup
        ])
        //sections
        let section = NSCollectionLayoutSection(group: group)
        //return
        return UICollectionViewCompositionalLayout(section: section)
    }


}

extension EditMomentViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }
    
    
}
//extension EditMomentViewController:UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        return CGSize(width: (collectionView.width)/3 - 6, height: (collectionView.width)/3 - 6)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//}

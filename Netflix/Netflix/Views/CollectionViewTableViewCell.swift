//
//  CollectionViewTableViewCell.swift
//  Netflix
//
//  Created by Sudharshan on 26/11/22.
//

import UIKit


protocol CollectionViewtbaleViewDelegate {
    func collectionViewTableViewcellDidTap(_ cell: CollectionViewTableViewCell, viewModal: TitlePreViewViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {

    static let identifier = "CollectionViewTableViewCell"
    private var titles: [Title] = []
    
    var delegate: CollectionViewtbaleViewDelegate?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collectionView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with titles: [Title]) {
        self.titles = titles
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    private func downloadTitleAt(indexPath: IndexPath){
        
        DataPersistanceManager.shared.downloadTitleWith(model: titles[indexPath.row]){ result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("DownlodedToDatabase"), object: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else{return UICollectionViewCell()}
        guard let model = titles[indexPath.row].poster_path else{return UICollectionViewCell()}
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else {return}
        
        APICaller.shared.getMoviewithQuery(with: titleName + "trailer") { [weak self] result in
            switch result {
            case .success(let videoElement):
                var title = self?.titles[indexPath.row]
                guard let titleOverView = title?.overview else {return}
                guard let strongSelf = self else{return}
                let viewModel = TitlePreViewViewModel(title: titleName, youTubeview: videoElement, titleOverView: titleOverView)
                self?.delegate?.collectionViewTableViewcellDidTap(strongSelf, viewModal: viewModel)
                
            case .failure(let error):
                print(error.localizedDescription)
                    
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil){ [weak self] _ in
            let downloadAction = UIAction(title: "Download", subtitle: "", image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) { _ in
                
                self?.downloadTitleAt(indexPath: indexPaths[0])
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction])
        }
       return config
    }
    
    
    
}

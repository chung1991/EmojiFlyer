//
//  ViewController.swift
//  EmojiFlyer
//
//  Created by Chung Nguyen on 6/14/22.
//

import UIKit

class ViewModel {
    var emojis: [String] = []
    
    init() {
        
    }
    
    func loadAllEmojis() {
        emojis = []
        for i in 0x1F601...0x1F64F {
            let c = String(UnicodeScalar(i) ?? "-")
            emojis.append(c)
        }
    }
}

protocol EmojiViewControllerDelegate: AnyObject {
    func didDismiss(_ string: String)
}

class EmojiViewController: UIViewController {
    let viewModel = ViewModel()
    weak var delegate: EmojiViewControllerDelegate?
    lazy var collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupAutolayout()
        setupDelegates()
        
        viewModel.loadAllEmojis()
        collectionView.reloadData()
    }
    
    func setupViews() {
        view.addSubview(collectionView)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    func setupAutolayout() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupDelegates() {
        
    }
}

extension EmojiViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionSize.shared.linespacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionSize.shared.interium
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CollectionSize.shared.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? EmojiCell else {
            return UICollectionViewCell()
        }
        let string = viewModel.emojis[indexPath.row]
        cell.label.text = string
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let string = viewModel.emojis[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didDismiss(string)
        }
    }
}

class EmojiCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupAutolayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(label)
    }
    
    func setupAutolayout() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.label.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure(_ string: String) {
        
    }
}

class ViewController: UIViewController {
    lazy var button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupAutolayout()
        setupDelegates()
    }
    
    func setupViews() {
        CollectionSize.shared.setConstraint(itemSize: CGSize(width: 40, height: 40),
                                            interium: 5,
                                            linespacing: 5,
                                            row: 15,
                                            col: 10)
        // add button
        view.addSubview(button)
        button.setBackgroundImage(UIImage(systemName: "arrow.up.circle"), for: .normal)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapButton))
        tapGesture.numberOfTapsRequired = 1
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didHoldButton))
        button.addGestureRecognizer(tapGesture)
        button.addGestureRecognizer(longPressGesture)
    }
    
    func setupAutolayout() {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.widthAnchor.constraint(equalToConstant: 80),
            button.heightAnchor.constraint(equalToConstant: 80),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
    }
    
    func setupDelegates() {
        
    }
    
    @objc func didTapButton() {
        guard let string = button.title(for: .normal) else {
            return
        }
        
        let label = UILabel()
        label.text = string
        label.font = label.font.withSize(23)
        label.frame = CGRect(x: button.frame.minX,
                             y: button.frame.minY,
                             width: 200.0,
                             height: 200.0)
        view.addSubview(label)
        
        let height = view.frame.height
        UIView.animate(withDuration: 4.0) {
            let randomX = Double.random(in: -500...500)
            let transform = CGAffineTransform(translationX: randomX, y: -height*2)
            //transform.rotated(by: 20.0)
            transform.rotated(by: 800.0)
            label.transform = transform
            
        }
    }
    
    @objc func didHoldButton() {
        print ("long tap")
        showEmojiPopover()
    }
    
    func showEmojiPopover() {
        let vc = EmojiViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = button
        vc.popoverPresentationController?.sourceRect = button.bounds
        vc.preferredContentSize = CollectionSize.shared.getContentSize()
        present(vc, animated: true, completion: nil)
    }
}

extension ViewController: EmojiViewControllerDelegate {
    func didDismiss(_ string: String) {
        DispatchQueue.main.async { [weak self] in
            self?.button.setBackgroundImage(nil, for: .normal)
            self?.button.setTitle(string, for: .normal)
        }
    }
}

class CollectionSize {
    static let shared = CollectionSize()
    var itemSize: CGSize = CGSize(width: 20, height: 20)
    var interium: CGFloat = 0
    var linespacing: CGFloat = 0
    var row: CGFloat = 20.0
    var col: CGFloat = 2.0
    func setConstraint(itemSize: CGSize, interium: CGFloat, linespacing: CGFloat, row: Int, col: Int) {
        self.itemSize = itemSize
        self.interium = interium
        self.linespacing = linespacing
        self.row = CGFloat(row)
        self.col = CGFloat(col)
    }
    
    func getContentSize() -> CGSize {
        let width = row * itemSize.width + (row - 1) * interium
        let height = col * itemSize.height + (col - 1) * linespacing
        return CGSize(width: width, height: height)
    }
}

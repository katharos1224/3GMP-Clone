//
//  AgencyCategoryTypeVC.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 24/01/2024.
//

import UIKit
import FFPopup
import SwipeCellKit

class AgencyCategoryTypeVC: BaseViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var agencyCategoryTypeData: [AgencyCategoryType] = []
    var type: String = ""
    var page: Int?
    var search: String?
    var titleName: String = ""
    var id: Int = -1
    var name: String = ""
    
    let cellWidth = Constants.WIDTH_SCREEN - 32
    let cellHeight = (4 / 27) * Constants.WIDTH_SCREEN
    let spacing = Constants.SPACING
    let padding = Constants.PADDING
    
    let createNewContentView: CreateAgencyCategoryTypeView = {
        let width = (4 / 5) * Constants.WIDTH_SCREEN
        let height = width * (23 / 40)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = CreateAgencyCategoryTypeView(frame: frame)
        return view
    }()
    
    let editContentView: CreateAgencyCategoryTypeView = {
        let width = (4 / 5) * Constants.WIDTH_SCREEN
        let height = width * (23 / 40)
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let view = CreateAgencyCategoryTypeView(frame: frame)
        return view
    }()

    var createNewPopupView = FFPopup()
    var editPopupView = FFPopup()

    init() {
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleName
        
        let layout = PagingCollectionViewLayout()
        layout.sectionInset = .init(top: padding, left: padding, bottom: padding, right: padding)
        layout.itemSize = .init(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = .white

        collectionView.registerCellFromNib(AgencyDetailCell.self, nibName: AgencyDetailCell.identifier)
    }
    
    override func viewWillAppear(_: Bool) {
        setupData()
    }
    
    func setupData() {
        NetworkManager.shared.fetchAgencyCategoryType(type: type, page: nil, search: nil) { [weak self] result in
            switch result {
            case .success(let data):
                guard let response = data.response else {
                    print(data.message)
                    return
                }
                
                self?.agencyCategoryTypeData = response.data
                
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                    self?.hideLoadingIndicator()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func showCreateNewPopup() {
        createNewContentView.addTextField.delegate = self
        createNewContentView.addTextField.becomeFirstResponder()
        
        createNewPopupView = FFPopup(contentView: createNewContentView, showType: .fadeIn, dismissType: .fadeOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
        
        createNewContentView.addOnClick = { [self] in
            guard let name = createNewContentView.addTextField.text, name != "" else {
                dismissCreatePopup()
                return
            }
            
            dismissCreatePopup()
            
            showLoadingIndicator()
            
            NetworkManager.shared.createAgencyCategoryType(type: type, name: name) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let response = data.response else {
                        print(data.message)
                        return
                    }
                    self?.agencyCategoryTypeData = response.data
                    
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                        self?.hideLoadingIndicator()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        createNewContentView.dismissOnClick = { [self] in
            dismissCreatePopup()
        }

        let layout = FFPopupLayout(horizontal: .center, vertical: .center)
        createNewPopupView.show(layout: layout)
    }
    
    func showEditNewPopup() {
        editContentView.addTextField.delegate = self
        editContentView.addTextField.becomeFirstResponder()
        editContentView.addTextField.text = self.name
        editContentView.titleLabel.text = "Đổi tên danh mục"
        editContentView.addButton.setTitle("Đổi tên", for: .normal)
        
        editPopupView = FFPopup(contentView: editContentView, showType: .fadeIn, dismissType: .fadeOut, maskType: .dimmed, dismissOnBackgroundTouch: true, dismissOnContentTouch: false)
        
        editContentView.addOnClick = { [self] in
            guard let name = editContentView.addTextField.text, name != "" else {
                dismissEditPopup()
                return
            }
            
            dismissEditPopup()
            
            showLoadingIndicator()
            
            NetworkManager.shared.editAgencyCategoryType(type: type, id: self.id, name: name) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let response = data.response else {
                        print(data.message)
                        return
                    }
                    self?.agencyCategoryTypeData = response.data
                    
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                        self?.hideLoadingIndicator()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        editContentView.dismissOnClick = { [self] in
            dismissEditPopup()
        }

        let layout = FFPopupLayout(horizontal: .center, vertical: .center)
        editPopupView.show(layout: layout)
    }

    func dismissCreatePopup() {
        DispatchQueue.main.async {
            self.createNewPopupView.dismiss(animated: true)
        }
    }
    
    func dismissEditPopup() {
        DispatchQueue.main.async {
            self.editPopupView.dismiss(animated: true)
        }
    }
    
    @IBAction func createTapped() {
        showCreateNewPopup()
    }
    
    @IBAction func dismissTapped() {
        popWithCrossDissolve()
    }
    
}

extension AgencyCategoryTypeVC: SwipeCollectionViewCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        let id = agencyCategoryTypeData[indexPath.item].value
        self.id = id
        self.name = agencyCategoryTypeData[indexPath.item].name
        
        guard orientation == .right else { return nil }
        
        // Action Delete
        let deleteAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            self.showLoadingIndicator()
            
            NetworkManager.shared.deleteAgencyCategoryType(type: self.type, id: id) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let response = data.response else {
                        print(data.message)
                        self?.collectionView.reloadData()
                        self?.hideLoadingIndicator()
                        return
                    }
                    self?.agencyCategoryTypeData = response.data
                    
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                        self?.hideLoadingIndicator()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.image?.withTintColor(.systemRed)
        deleteAction.backgroundColor = .white
        
        // Action Edit
        let editAction = SwipeAction(style: .default, title: "") { action, indexPath in
            self.showEditNewPopup()
        }
        
        editAction.image = UIImage(named: "square.and.pencil")
        editAction.highlightedImage?.withTintColor(.systemBlue)
        editAction.backgroundColor = .white
        
        return [deleteAction, editAction]
    }
    

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return agencyCategoryTypeData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AgencyDetailCell.identifier, for: indexPath) as! AgencyDetailCell
        cell.delegate = self
        
        let data = agencyCategoryTypeData[indexPath.item]
        
        cell.configure(data: data)
        
        return cell
    }
}

extension AgencyCategoryTypeVC: FloatingTextFieldDelegate, UITextFieldDelegate {
    
}

//
//  BaseViewController.swift
//  ThuocTot3Mien
//
//  Created by Katharos on 30/11/2023.
//

import AVFoundation
import Combine
import Photos
import UIKit

class BaseViewController: UIViewController {
    // MARK: - View Lifecycle

    var loadingIndicator: UIActivityIndicatorView?
    var autoScrollTimer: Timer?
    var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }

    override func viewWillAppear(_: Bool) {
        setupUI()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UI Configuration

    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        showLoadingIndicator()
    }
    
    @objc func baseTextFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    // MARK: - Navigation

    func pushWithCrossDissolve(_ viewController: UIViewController, animated _: Bool = true, completion: (() -> Void)? = nil) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade

        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(viewController, animated: false)

        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + transition.duration) {
                completion()
            }
        }
    }

    func popWithCrossDissolve(animated _: Bool = true, completion: (() -> Void)? = nil) {
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade

        navigationController?.view.layer.add(transition, forKey: kCATransition)
        _ = navigationController?.popViewController(animated: false)

        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + transition.duration) {
                completion()
            }
        }
    }

    func popToRoot() { let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade

        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.popToRootViewController(animated: false)
    }

    func push(_ viewController: UIViewController, animated: Bool = true, completion _: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool = true, completion _: (() -> Void)? = nil) {
        navigationController?.popViewController(animated: animated)
    }

    func show(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: animated, completion: completion)
    }

    func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        dismiss(animated: animated, completion: completion)
    }

    // MARK: - Image Picker

    func showImagePickerOptions() {
        let alertController = UIAlertController(title: "Chọn ảnh", message: nil, preferredStyle: .actionSheet)

        let chooseFromLibraryAction = UIAlertAction(title: "Chọn từ Thư viện", style: .default) { _ in
            self.checkLibraryPermission()
        }
        alertController.addAction(chooseFromLibraryAction)

        let takePhotoAction = UIAlertAction(title: "Chụp ảnh", style: .default) { _ in
            self.checkCameraPermission()
        }
        alertController.addAction(takePhotoAction)

        let cancelAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func checkLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            showImagePicker(sourceType: .photoLibrary)
        case .denied, .restricted, .limited:
            showPermissionAlert(type: "Thư viện ảnh")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    self.showImagePicker(sourceType: .photoLibrary)
                } else {
                    self.showPermissionAlert(type: "Thư viện ảnh")
                }
            }
        @unknown default:
            break
        }
    }

    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showImagePicker(sourceType: .camera)
        case .denied, .restricted:
            showPermissionAlert(type: "Camera")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.showImagePicker(sourceType: .camera)
                } else {
                    self.showPermissionAlert(type: "Camera")
                }
            }
        @unknown default:
            break
        }
    }

    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            DispatchQueue.main.async { [self] in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = sourceType
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }

    func showPermissionAlert(type: String) {
        let alertController = UIAlertController(
            title: "Quyền truy cập \(type) bị từ chối",
            message: "Vui lòng vào Cài đặt > Quyền riêng tư để bật quyền truy cập.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Cài đặt", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(settingsAction)

        let cancelAction = UIAlertAction(title: "Huỷ", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Alert

    func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = []) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)

        if actions.isEmpty {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
        } else {
            actions.forEach { alertController.addAction($0) }
        }

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Spinner

    func validatePhoneNumber(_ phone: String) -> Bool {
        return phone.count <= 10
    }

    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailPredicate.evaluate(with: email)
    }

    func validateTaxCode(_ taxCode: String) -> Bool {
        if taxCode.count == 10, taxCode.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            return true
        }

        if taxCode.count == 14,
           let indexOfDash = taxCode.firstIndex(of: "-"),
           taxCode.distance(from: taxCode.startIndex, to: indexOfDash) == 10,
           taxCode[taxCode.index(after: indexOfDash)...].rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        {
            return true
        }

        return false
    }
}

extension BaseViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {}

extension BaseViewController {
    func startAutoScroll(for collectionView: UICollectionView, with interval: TimeInterval = 3.0) {
        autoScrollTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(autoScrollAction), userInfo: ["collectionView": collectionView], repeats: true)
    }

    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    @objc private func autoScrollAction(timer: Timer) {
        guard let userInfo = timer.userInfo as? [String: UICollectionView],
              let collectionView = userInfo["collectionView"],
              let visibleIndexPath = collectionView.indexPathsForVisibleItems.first
        else {
            return
        }

        let lastItem = collectionView.numberOfItems(inSection: 0) - 1

        var nextIndexPath: IndexPath

        if visibleIndexPath.item < lastItem {
            nextIndexPath = IndexPath(item: visibleIndexPath.item + 1, section: 0)

            collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        } else {
            for index in 0 ... lastItem {
                nextIndexPath = IndexPath(item: lastItem - index, section: 0)

                collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: false)
            }
        }
    }
}

extension BaseViewController {
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .systemGreen
            indicator.startAnimating()

            let indicatorContainer = UIView(frame: self.view.bounds)
            indicatorContainer.backgroundColor = UIColor(white: 1, alpha: 1)
            indicatorContainer.tag = 9876
            indicatorContainer.addSubview(indicator)

            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: indicatorContainer.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: indicatorContainer.centerYAnchor),
            ])

            self.view.addSubview(indicatorContainer)
            self.loadingIndicator = indicator
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            if let indicatorContainer = self.view.viewWithTag(9876) {
                indicatorContainer.removeFromSuperview()
                self.loadingIndicator = nil
            }
        }
    }
}

//
//  ModalViewController.swift
//  ios-twitter-transition
//
//  Created by OkuderaYuki on 2018/01/08.
//  Copyright © 2018年 SmartTech Ventures Inc. All rights reserved.
//

import UIKit

final class ModalViewController: UIViewController {

    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!

    private var imageSlideOutTransition = ImageSlideOutTransition()
    private var interactiveTransitionController: UIPercentDrivenInteractiveTransition?
    private var isTransitioning = false

    // MARK: - Factory

    class func make() -> ModalViewController {
        guard let modalVC = UIStoryboard.viewController(
            storyboardName: "ModalViewController",
            identifier: "ModalViewController") as? ModalViewController else {
                fatalError("ModalViewController is nil.")
        }
        return modalVC
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // テスト用のイメージ
        imageView.image = #imageLiteral(resourceName: "image1")

        self.transitioningDelegate = self
        panGestureRecognizer.delegate = self
    }

    // MARK: - Actions

    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        if scrollView.zoomScale > 1.0 || scrollView.contentOffset.x != 0 {
            return
        }

        switch sender.state {
        case .began:
            // ジェスチャの開始。遷移を開始・上下方向を決定する。
            isTransitioning = true
            scrollView.isScrollEnabled = false
            interactiveTransitionController = UIPercentDrivenInteractiveTransition()

            if sender.translation(in: scrollView).y > 0 {
                imageSlideOutTransition.isScrolledUp = false
            } else {
                imageSlideOutTransition.isScrolledUp = true
            }
            dismiss(animated: true, completion: nil)
            updateTransitionProgress(sender: sender)

        case .cancelled:
            // ジェスチャキャンセル。遷移をキャンセルする
            endTransitioning()
            cancelInteractiveTransition()

        case .changed:
            // ジェスチャ中。遷移の進行度を更新する
            if isTransitioning {
                // 方向が変更される場合、一旦キャンセルして初期化し直す
                if imageSlideOutTransition.isScrolledUp && sender.translation(in: scrollView).y > 0 {
                    reInitDismiss(isScrolledUp: false)
                } else if !imageSlideOutTransition.isScrolledUp && sender.translation(in: scrollView).y < 0 {
                    reInitDismiss(isScrolledUp: true)
                }
                updateTransitionProgress(sender: sender)
            }

        case .ended:
            // ジェスチャの正常完了。遷移を実行させるかキャンセルする。
            endTransitioning()

            guard let interactiveTransitionController = interactiveTransitionController else {
                break
            }

            // 進行度0.5以上なら遷移実行へ
            if interactiveTransitionController.percentComplete >= CGFloat(0.5) {
                finishInteractiveTransition()
                break
            }

            // スワイプの勢いが一定以上なら遷移実行へ
            let velocityinView = sender.velocity(in: scrollView).y
            if fabs(velocityinView) > 1000 {
                if imageSlideOutTransition.isScrolledUp && velocityinView < 0 {
                    finishInteractiveTransition()
                } else if !imageSlideOutTransition.isScrolledUp && velocityinView > 0 {
                    // 下へスクロール
                    finishInteractiveTransition()
                } else {
                    cancelInteractiveTransition()
                }
            } else {
                cancelInteractiveTransition()
            }

        case .failed:
            // ジェスチャの失敗。遷移をキャンセルする。
            endTransitioning()
            cancelInteractiveTransition()

        default:
            break
        }
    }

    /// 遷移の進行度を更新する
    private func updateTransitionProgress(sender: UIPanGestureRecognizer) {
        let transitionProgress: CGFloat = sender.translation(in: scrollView).y / view.frame.size.height
        interactiveTransitionController?.update(fabs(transitionProgress))
    }

    /// 遷移フラグを折って、スクロールビューのスクロールを許可する
    private func endTransitioning() {
        isTransitioning = false
        scrollView.isScrollEnabled = true
    }

    /// 方向が変更される場合、一旦キャンセルして初期化し直す
    private func reInitDismiss(isScrolledUp: Bool) {
        interactiveTransitionController?.cancel()
        interactiveTransitionController = UIPercentDrivenInteractiveTransition()
        imageSlideOutTransition.isScrolledUp = isScrolledUp
        dismiss(animated: true, completion: nil)
    }

    /// 画面遷移実行する
    private func finishInteractiveTransition() {
        interactiveTransitionController?.finish()
        interactiveTransitionController = nil
    }

    /// 画面遷移実行しない
    private func cancelInteractiveTransition() {
        interactiveTransitionController?.cancel()
        interactiveTransitionController = nil
    }
}

extension ModalViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return imageSlideOutTransition
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return self.interactiveTransitionController
    }
}

extension ModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if otherGestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            return false
        } else {
            return true
        }
    }
}

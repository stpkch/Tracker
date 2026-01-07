import UIKit

final class OnboardingPageViewController: UIPageViewController {

    var onFinish: (() -> Void)?

    private let pageControl = UIPageControl()
    private let actionButton = UIButton(type: .system)

    private lazy var pages: [UIViewController] = {
        [
            OnboardingContentViewController(
                image: UIImage(named: "onboardingBlue")!,
                text: NSLocalizedString("onboarding.page1.text", comment: "")
            ),
            OnboardingContentViewController(
                image: UIImage(named: "onboardingRed")!,
                text: NSLocalizedString("onboarding.page2.text", comment: "")
            )
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        setViewControllers([pages[0]], direction: .forward, animated: false)

        setupPageControl()
        setupButton()
    }

    private func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.isUserInteractionEnabled = false

        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -96)
        ])
    }

    private func setupButton() {
        actionButton.setTitle(NSLocalizedString("onboarding.button", comment: ""), for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.backgroundColor = .black
        actionButton.layer.cornerRadius = 16
        actionButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        actionButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        view.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func didTapButton() {
        onFinish?()
    }

    private func index(of vc: UIViewController) -> Int? {
        pages.firstIndex(where: { $0 === vc })
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let i = index(of: viewController), i > 0 else { return nil }
        return pages[i - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let i = index(of: viewController), i < pages.count - 1 else { return nil }
        return pages[i + 1]
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let current = viewControllers?.first,
              let i = index(of: current)
        else { return }

        pageControl.currentPage = i
    }
}

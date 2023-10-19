//
//  DetailsViewController.swift
//  Movies
//
//  Created by Anton Petrov on 19.10.2023.
//

import UIKit
import Kingfisher

final class DetailsViewController: UIViewController {
    // MARK: - UI Elements

    private let backgroundImageView = UIImageView()
    private let containerScrollView = UIScrollView()
    private let verticalContainerStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = Constants.StyleDefaults.mediumPadding
    }

    private let posterImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.layer.shadowRadius = 10
        $0.layer.shadowOpacity = 0.6
        $0.layer.cornerRadius = Constants.StyleDefaults.cornerRadius
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }

    private let titleLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 22, weight: .heavy)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let countryLabel = UILabel().configure {
        $0.font = .italicSystemFont(ofSize: 18)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let genresLabel = UILabel().configure {
        $0.lineBreakMode = .byWordWrapping
        $0.textAlignment = .center
        $0.font = .boldSystemFont(ofSize: 14)
        $0.numberOfLines = 0
    }

    private let activityIndicator = UIActivityIndicatorView()
    private let horizontalStackView = UIStackView().configure {
        $0.distribution = .equalCentering
        $0.spacing = 10
    }

    private let movieTrailerImageView = UIImageView().configure {
        $0.tintColor = .black
        $0.isUserInteractionEnabled = true
        $0.image = Constants.SystemImage.playButton.image
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 1
        $0.isHidden = true
    }
    private let movieTrailerPlaceholder = UIView()

    private let ratingView = RatingView()
    private let descriptionLabel = UILabel().configure {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .italicSystemFont(ofSize: 16)
    }

    private let noPosterLabel = UILabel().configure {
        $0.text = LocalizedKey.noPosterLabel.localizedString
        $0.textColor = .white
        $0.backgroundColor = .black
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.isHidden = true
        $0.layer.cornerRadius = Constants.StyleDefaults.cornerRadius
        $0.font = .boldSystemFont(ofSize: 20)
    }

    // MARK: - Properties

    private let viewModel: MovieDetailsViewModelProtocol
    private let mediumPadding = Constants.StyleDefaults.mediumPadding
    private let pointSeparator = Constants.StyleDefaults.pointSeparator
    private let bigItemSideSize = Constants.StyleDefaults.bigItemSideSize
    private let lineSeparator = "\n"
    private let posterAspectRatio: CGFloat = 10/15

    // MARK: - Initialization

    init(viewModel: MovieDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupLayout()
        setupImages()
        setupDetails()
        getTrailer()
    }

    // MARK: - Actions

    @objc private func trailerButtonDidTap() {
        viewModel.navigateToTrailer()
    }

    @objc private func didTapPosterImageView() {
        viewModel.navigateToFullscreenPosterImage()
    }

    @objc private func didTapBackButton() {
        viewModel.pop()
    }

    // MARK: - Interactions

    private func getTrailer() {
        activityIndicator.startAnimating()
        viewModel.getLatestTrailer { [weak self] hasTrailer in
            guard let self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.removeFromSuperview()
                self.movieTrailerImageView.isHidden = !hasTrailer
                self.movieTrailerPlaceholder.isHidden = hasTrailer
            }
        }
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = viewModel.movieDetails.title
        let icon = Constants.SystemImage.backButton.image
        let item = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem = item
    }

    private func setupLayout() {
        view.insertSubview(backgroundImageView, at: 0)
        backgroundImageView.fillSuperviewSafeArea()
        backgroundImageView.applyBlurEffect()
        view.addSubview(containerScrollView)
        containerScrollView.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                                   left: view.leftAnchor,
                                   bottom: view.bottomAnchor,
                                   right: view.rightAnchor)
        containerScrollView.addSubview(verticalContainerStackView)
        verticalContainerStackView.anchor(top: containerScrollView.topAnchor,
                         left: containerScrollView.leftAnchor,
                         bottom: containerScrollView.bottomAnchor,
                         right: containerScrollView.rightAnchor,
                         paddingLeft: mediumPadding,
                         paddingRight: mediumPadding)
        verticalContainerStackView.setWidth(view.frame.width - mediumPadding * 2)
        verticalContainerStackView.addArrangedSubview(posterImageView)
        posterImageView.setDimensions(height: view.frame.width, width: view.frame.width * posterAspectRatio)
        posterImageView.addSubview(noPosterLabel)
        noPosterLabel.fillSuperview()
        verticalContainerStackView.addArrangedSubview(titleLabel)
        verticalContainerStackView.addArrangedSubview(countryLabel)
        verticalContainerStackView.addArrangedSubview(horizontalStackView)
        verticalContainerStackView.addArrangedSubview(descriptionLabel)
        setupHorizontalStackLayout()
    }

    private func setupHorizontalStackLayout() {
        horizontalStackView.setWidth(view.frame.width - mediumPadding * 2)
        horizontalStackView.addArrangedSubview(movieTrailerImageView)
        movieTrailerImageView.setDimensions(height: bigItemSideSize, width: bigItemSideSize)
        movieTrailerImageView.layer.cornerRadius = bigItemSideSize / 2
        horizontalStackView.addArrangedSubview(movieTrailerPlaceholder)
        movieTrailerPlaceholder.setDimensions(height: bigItemSideSize, width: bigItemSideSize)
        horizontalStackView.addArrangedSubview(genresLabel)
        horizontalStackView.addArrangedSubview(ratingView)
        ratingView.setDimensions(height: bigItemSideSize, width: bigItemSideSize)
    }

    private func setupImages() {
        guard let urlString = viewModel.movieDetails.posterImageURLString, let url = URL(string: urlString)
        else {
            noPosterLabel.isHidden = false
            return
        }
        backgroundImageView.kf.setImage(with: url)
        posterImageView.kf.setImage(with: url) { result in
            switch result {
            case .success:
                self.noPosterLabel.isHidden = true
            case .failure:
                self.noPosterLabel.isHidden = false
            }
        }
    }

    private func setupDetails() {
        let movieDetails = viewModel.movieDetails
        title = movieDetails.year
        let countries = movieDetails.countries.joined(separator: lineSeparator)
        countryLabel.text = countries
        titleLabel.text = movieDetails.title
        genresLabel.text = movieDetails.genres.map { $0.name }.joined(separator: lineSeparator)
        ratingView.configure(withRating: movieDetails.rating, votes: movieDetails.votes)
        descriptionLabel.text = movieDetails.overview
    }

    private func setupSelectors() {
        let posterTap = UITapGestureRecognizer(target: self, action: #selector(didTapPosterImageView))
        posterImageView.addGestureRecognizer(posterTap)
        let trailerTap = UITapGestureRecognizer(target: self, action: #selector(trailerButtonDidTap))
        posterImageView.addGestureRecognizer(trailerTap)
    }
}
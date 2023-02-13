import UIKit

final class MovieQuizViewController: UIViewController  {
    // MARK: - Lifecycle
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {            presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked (_ sender: UIButton){        presenter.noButtonClicked()
    }
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        presenter = MovieQuizPresenter(viewController: self)
    }

    func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.presenter.restartGame()
        }

        alert.addAction(action)
    }
   
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.presenter.restartGame()
            self.imageView.layer.borderWidth = 0
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor :UIColor.ypRed.cgColor
    }
}

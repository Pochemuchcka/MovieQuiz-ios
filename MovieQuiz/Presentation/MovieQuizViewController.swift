import UIKit

final class MovieQuizViewController: UIViewController,QuestionFactoryDelegate,AlertPresenterDelegate  {
    // MARK: - Lifecycle
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {            presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked (_ sender: UIButton){        presenter.noButtonClicked()
    }
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = 0
    private var numberOfGames: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        presenter.viewController = self

    }
    
    
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.showAlert(model: model)
    }
   
    func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {

        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, completion: {
            [weak self] in
            guard let self = self else {return}
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.imageView.layer.borderWidth = 0
            self.numberOfGames += 1
            self.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        switchButton()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.contents = 0
            self.showNextQuestionOrResults()
            
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
        
    }

    func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            let bestGameStats = "\(bestGame.correct)/\(bestGame.total)"

            
            let text = """
                    Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                    Кол-во сыгранных квизов: \(statisticService.gamesCount)
                    Рекорд: \(bestGameStats) \(bestGame.date.dateTimeString)
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100) + "%")
            """
            
            let vieModel = QuizResultsViewModel(title: "Раунд окончен!", text: text, buttonText: "Cыграть ещё раз!")
            show(quiz: vieModel)
        } else {
            imageView.layer.borderWidth = 0
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func switchButton()  {
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
}

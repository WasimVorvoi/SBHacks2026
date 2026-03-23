import UIKit

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {

    private var selectedDate = Date()
    private var currentMonth = Date()
    private var daysInMonth: [Date?] = []

    private let monthLabel = UILabel()
    private let collectionView: UICollectionView
    private let tableView = UITableView()
    private let selectedDayLabel = UILabel()
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]
    private let emptyDayLabel = UILabel()
    private var animatedCells: Set<IndexPath> = []

    private var tasksForSelectedDate: [TaskItem] {
        return TaskStore.shared.tasksForDate(selectedDate)
    }

    override init(nibName: String?, bundle: Bundle?) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Calendar"
        view.backgroundColor = Theme.bg
        navigationItem.largeTitleDisplayMode = .always
        setupUI()
        generateDays()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        tableView.reloadData()
        updateSelectedDayLabel()
    }

    private func setupUI() {
        let calendarCard = UIView()
        Theme.applyCard(to: calendarCard, cornerRadius: 14)
        calendarCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarCard)

        let prevBtn = UIButton(type: .system)
        prevBtn.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        prevBtn.tintColor = Theme.neon
        prevBtn.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)

        monthLabel.font = .rounded(ofSize: 20, weight: .bold)
        monthLabel.textColor = Theme.text
        monthLabel.textAlignment = .center

        let nextBtn = UIButton(type: .system)
        nextBtn.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)), for: .normal)
        nextBtn.tintColor = Theme.neon
        nextBtn.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)

        let navStack = UIStackView(arrangedSubviews: [prevBtn, monthLabel, nextBtn])
        navStack.distribution = .equalSpacing
        navStack.translatesAutoresizingMaskIntoConstraints = false
        calendarCard.addSubview(navStack)

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.distribution = .fillEqually
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        calendarCard.addSubview(headerStack)

        for day in dayLabels {
            let label = UILabel()
            label.text = day
            label.font = .systemFont(ofSize: 13, weight: .semibold)
            label.textAlignment = .center
            label.textColor = Theme.textMuted
            headerStack.addArrangedSubview(label)
        }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        calendarCard.addSubview(collectionView)

        selectedDayLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        selectedDayLabel.textColor = Theme.textDim
        selectedDayLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedDayLabel)

        emptyDayLabel.text = "No tasks for this day"
        emptyDayLabel.font = .systemFont(ofSize: 14)
        emptyDayLabel.textColor = Theme.textMuted
        emptyDayLabel.textAlignment = .center
        emptyDayLabel.isHidden = true
        emptyDayLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyDayLabel)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            calendarCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            calendarCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            calendarCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            navStack.topAnchor.constraint(equalTo: calendarCard.topAnchor, constant: 14),
            navStack.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 16),
            navStack.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -16),

            headerStack.topAnchor.constraint(equalTo: navStack.bottomAnchor, constant: 14),
            headerStack.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 8),
            headerStack.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -8),

            collectionView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 6),
            collectionView.leadingAnchor.constraint(equalTo: calendarCard.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: calendarCard.trailingAnchor, constant: -8),
            collectionView.heightAnchor.constraint(equalToConstant: 260),
            collectionView.bottomAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: -12),

            selectedDayLabel.topAnchor.constraint(equalTo: calendarCard.bottomAnchor, constant: 16),
            selectedDayLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            emptyDayLabel.topAnchor.constraint(equalTo: selectedDayLabel.bottomAnchor, constant: 30),
            emptyDayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: selectedDayLabel.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateSelectedDayLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        selectedDayLabel.text = formatter.string(from: selectedDate)
        emptyDayLabel.isHidden = !tasksForSelectedDate.isEmpty
    }

    private func generateDays() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstOfMonth = calendar.date(from: components) else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: currentMonth)

        let weekday = calendar.component(.weekday, from: firstOfMonth)
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!

        daysInMonth = []
        for _ in 1..<weekday { daysInMonth.append(nil) }
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                daysInMonth.append(date)
            }
        }

        animatedCells.removeAll()
        collectionView.reloadData()
        tableView.reloadData()
        updateSelectedDayLabel()
    }

    @objc private func prevMonth() {
        Theme.hapticLight()
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
        let direction: CGFloat = -1
        UIView.animate(withDuration: 0.15, animations: {
            self.collectionView.transform = CGAffineTransform(translationX: direction * 30, y: 0)
            self.collectionView.alpha = 0
        }) { _ in
            self.generateDays()
            self.collectionView.transform = CGAffineTransform(translationX: -direction * 30, y: 0)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
                self.collectionView.transform = .identity
                self.collectionView.alpha = 1
            }
        }
    }

    @objc private func nextMonth() {
        Theme.hapticLight()
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
        let direction: CGFloat = 1
        UIView.animate(withDuration: 0.15, animations: {
            self.collectionView.transform = CGAffineTransform(translationX: direction * 30, y: 0)
            self.collectionView.alpha = 0
        }) { _ in
            self.generateDays()
            self.collectionView.transform = CGAffineTransform(translationX: -direction * 30, y: 0)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
                self.collectionView.transform = .identity
                self.collectionView.alpha = 1
            }
        }
    }

    // MARK: - Collection View

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return daysInMonth.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! CalendarDayCell
        if let date = daysInMonth[indexPath.item] {
            let day = Calendar.current.component(.day, from: date)
            let tasks = TaskStore.shared.tasksForDate(date)
            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
            let isToday = Calendar.current.isDateInToday(date)
            cell.configure(day: day, taskCount: tasks.count, isSelected: isSelected, isToday: isToday, maxDifficulty: tasks.map(\.difficulty).max())
        } else {
            cell.configure(day: nil, taskCount: 0, isSelected: false, isToday: false, maxDifficulty: nil)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard !animatedCells.contains(indexPath) else { return }
        animatedCells.insert(indexPath)
        cell.alpha = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: Double(indexPath.item) * 0.01, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = daysInMonth[indexPath.item] else { return }
        Theme.hapticLight()
        selectedDate = date

        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: []) {
            collectionView.visibleCells.forEach { cell in
                if let calCell = cell as? CalendarDayCell {
                    calCell.updateSelection(isSelected: collectionView.indexPath(for: cell) == indexPath)
                }
            }
        }

        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
        updateSelectedDayLabel()
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksForSelectedDate.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.configure(with: tasksForSelectedDate[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
}

// MARK: - Flow Layout

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 24) / 7
        return CGSize(width: width, height: 38)
    }
}

// MARK: - Calendar Day Cell

class CalendarDayCell: UICollectionViewCell {
    private let dayLabel = UILabel()
    private let dot = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        dayLabel.font = .rounded(ofSize: 14, weight: .medium)
        dayLabel.textAlignment = .center
        dayLabel.textColor = Theme.text
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dayLabel)

        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 3
        contentView.addSubview(dot)

        contentView.layer.cornerRadius = 10

        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -3),
            dot.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dot.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 1),
            dot.widthAnchor.constraint(equalToConstant: 6),
            dot.heightAnchor.constraint(equalToConstant: 6)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(day: Int?, taskCount: Int, isSelected: Bool, isToday: Bool, maxDifficulty: Int?) {
        if let day = day {
            dayLabel.text = "\(day)"
            dayLabel.isHidden = false
        } else {
            dayLabel.text = nil
            dayLabel.isHidden = true
        }

        dot.isHidden = taskCount == 0
        if let diff = maxDifficulty {
            dot.backgroundColor = Theme.difficultyColor(for: diff)
        }

        applyStyle(isSelected: isSelected, isToday: isToday)
    }

    func updateSelection(isSelected: Bool) {
        applyStyle(isSelected: isSelected, isToday: false)
    }

    private func applyStyle(isSelected: Bool, isToday: Bool) {
        if isSelected {
            contentView.backgroundColor = Theme.accent
            dayLabel.textColor = .white
            dayLabel.font = .rounded(ofSize: 14, weight: .bold)
        } else if isToday {
            contentView.backgroundColor = Theme.accentDim
            dayLabel.textColor = Theme.neon
            dayLabel.font = .rounded(ofSize: 14, weight: .bold)
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = Theme.text
            dayLabel.font = .rounded(ofSize: 14, weight: .medium)
        }
    }
}

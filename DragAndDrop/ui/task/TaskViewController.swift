//
//  TaskViewController.swift
//  DragAndDrop
//
//  Created by Dzaky on 25/11/21.
//

import UIKit
import PanModal
import MaterialComponents.MaterialTextControls_FilledTextAreas

protocol TaskDelegate: AnyObject {
    func didEditTask(task: String, index: Int)
    func didDeleteTask(task: String, index: Int)
}

class TaskViewController: UIViewController {
    
    weak var delegate: TaskDelegate?
    var task: String? = ""
    
    private let closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Task Detail"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.sizeToFit()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let taskTextArea: MDCFilledTextArea = {
        let textArea = MDCFilledTextArea()
        textArea.label.text = "Task"
        textArea.placeholder = "Some Task"
        textArea.becomeFirstResponder()
        textArea.sizeToFit()
        textArea.translatesAutoresizingMaskIntoConstraints = false
        return textArea
    }()
    
    private let stackViewAction: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = NSLayoutConstraint.Axis.horizontal
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    
    private let deleteButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Delete", for: .normal)
        btn.setTitleColor(.red, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskTextArea.textView.becomeFirstResponder()
    }
    
}

extension TaskViewController {
    
    func setup(task: String, index: Int) {
        self.task = task
        self.saveButton.tag = index
        self.deleteButton.tag = index
    }
    
    private func setupView() {
        // Dismiss keyboard when text area is active
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        view.addGestureRecognizer(tap)
        
        // disable button when user first time open
        disableButton(for: self.saveButton)
        
        // Title and Close Button
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        
        // Text Area
        taskTextArea.textView.text = task
        taskTextArea.textView.delegate = self
        view.addSubview(taskTextArea)
        
        // Stackview Action
        stackViewAction.addArrangedSubview(deleteButton)
        stackViewAction.addArrangedSubview(saveButton)
        view.addSubview(stackViewAction)
        
        // Adding constraint
        addConstraint()
        
        // Adding Action
        closeButton.addTarget(self,
                              action: #selector(closeButtonAction(_:)),
                              for: .touchUpInside)
        saveButton.addTarget(self,
                             action: #selector(saveEditAction(_:)),
                             for: .touchUpInside)
        deleteButton.addTarget(self,
                               action: #selector(deleteAction(_:)),
                               for: .touchUpInside)
    }
    
    private func addConstraint() {
        var constraint = [NSLayoutConstraint]()
        
        constraint.append(closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32))
        constraint.append(closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraint.append(closeButton.widthAnchor.constraint(equalToConstant: 24))
        
        // Title
        constraint.append(titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32))
        constraint.append(titleLabel.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: -(closeButton.bounds.size.width + 16)))
        constraint.append(titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        
        // Task Text Area
        constraint.append(taskTextArea.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32))
        constraint.append(taskTextArea.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraint.append(taskTextArea.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        
        // Save Button
        constraint.append(stackViewAction.topAnchor.constraint(equalTo: taskTextArea.bottomAnchor, constant: 32))
        constraint.append(stackViewAction.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraint.append(stackViewAction.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        
        NSLayoutConstraint.activate(constraint)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        taskTextArea.endEditing(true)
    }
    
    @objc func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func saveEditAction(_ sender: UIButton) {
        self.delegate?.didEditTask(task: self.taskTextArea.textView.text, index: self.saveButton.tag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Are you sure delete this task?", message: "Deleted task can't be returned", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
            self.delegate?.didDeleteTask(task: self.taskTextArea.textView.text, index: self.deleteButton.tag)
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func disableButton(for button: UIButton) {
        button.isEnabled = false
        button.alpha = 0.3
    }
    
    private func enableButton(for button: UIButton) {
        button.isEnabled = true
        button.alpha = 1.0
    }
    
}

extension TaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == self.task || textView.text.isEmpty {
            disableButton(for: self.saveButton)
        } else {
            enableButton(for: self.saveButton)
        }
    }
    
}


extension TaskViewController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeight
    }
    
    var anchorModalToLongForm: Bool {
        return true
    }
    
    //    var shortFormHeight: PanModalHeight {
    //        return .contentHeight(200)
    //    }
}

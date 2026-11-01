import Foundation
import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @Query(sort: \TodoTask.createdAt, order: .reverse)
    private var tasks: [TodoTask]
    
    @State private var newTaskTitle = ""
    @State private var noDate = false
    @State private var showCalendar = false
    @State private var taskToEdit: TodoTask? = nil
    @State private var editedTitle = ""
    @State private var editedDueDate = Date()
    @State private var editedNoDate = false
    @State private var editedPriority = 1
    @State private var newTaskPriotity = 1
    @State private var showCompleted = true
    @State private var selectedFilter = "All"
    @State private var selectedSort = "Newest"
    
    @State private var selectedDueDate = Date()
    
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay = Calendar.current.component(.day, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Lockedin")
                .font(.largeTitle)
                .bold()
            
            Text("Focus on what matters today.")
                .foregroundStyle(.secondary)
            
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    TextField(
                        "Enter a task...",
                        text: $newTaskTitle
                    )
                    .textFieldStyle(.plain)
                    .onSubmit(addTask)
                    
                    Button {
                        showCalendar.toggle()
                        
                    } label: {
                        Image(systemName: "calendar")
                    }
                    .buttonStyle(.plain)
                    
                    .popover(isPresented: $showCalendar) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Toggle("No Date", isOn: $noDate)
                            
                            HStack(spacing: 10) {
                                VStack(alignment: .leading) {
                                    Text("Month")
                                        .font(.caption)
                                    Picker("Month", selection: $selectedMonth) {
                                        ForEach(1...12, id: \.self) { month in
                                            
                                            Text(Calendar.current.monthSymbols[month - 1])
                                                .tag(month)
                                        }
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(width: 145)
                                
                                VStack(alignment: .leading) {
                                    Text("Day")
                                        .font(.caption)
                                    
                                    Picker("Day", selection: $selectedDay) {
                                        ForEach(1...31, id: \.self) { day in
                                            
                                            Text("\(day)")
                                                .tag(day)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 70)
                                }
                                VStack(alignment: .leading) {
                                    Text("Year")
                                        .font(.caption)
                                    
                                    Picker("Year", selection: $selectedYear) {
                                        ForEach(2000...2100, id: \.self) { year in
                                            
                                            Text("\(year)")
                                                .tag(year)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .labelsHidden()
                                    .frame(width: 90)
                                }
                            }
                            
                            Button("Done") {
                                showCalendar = false
                            }
                        }
                        .padding()
                        .frame(width: 400)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.secondary.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.25), lineWidth: 1)
                )
                
                Picker("Priority", selection: $newTaskPriotity) {
                    Text("Low").tag(0)
                    Text("Medium").tag(1)
                    Text("High").tag(2)
                }
                .pickerStyle(.menu)
                .frame(width: 150)
                
                Button("Add Task", action: addTask)
                    .disabled(
                        newTaskTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
            }
            
            Picker("Filter", selection: $selectedFilter) {
                Text("All").tag("All")
                Text("Today").tag("Today")
                Text("Upcoming").tag("Upcoming")
                Text("OVERDUE").tag("OVERDUE")
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 360)
            
            Picker("Sort by", selection: $selectedSort){
                Text("Newest").tag("Newest")
                Text("Due date").tag("Due date")
                Text("Priority").tag("Priority")
            }
            .pickerStyle(.menu)
            .frame(width: 220)
            
            Toggle("Show completed", isOn: $showCompleted)
            List {
                ForEach(filteredTasks, id: \.id) { task in
                    HStack {
                        Button {
                            task.isCompleted.toggle()
                            saveChanges()
                        } label: {
                            Image(systemName: task.isCompleted
                                  ? "checkmark.circle.fill"
                                  : "circle")
                        }
                        .buttonStyle(.plain)
                        
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .strikethrough(task.isCompleted)
                                .foregroundStyle(task.isCompleted
                                                 ? Color.secondary
                                                 : Color.primary
                                )
                            
                            Label(
                                task.priority == 2 ? "High Priority" :
                                    task.priority == 1 ? "Medium Priority" : "Low Priority",
                                systemImage:"flag.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                task.priority == 2 ? Color.red:
                                    task.priority == 1 ? Color.orange : Color.secondary
                            )
                            
                            if let dueDate = task.dueDate {
                                
                                
                                Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))").font(.caption)
                                
                                    .foregroundStyle(
                                        dueDate < Calendar.current.startOfDay(for: Date())
                                        && !task.isCompleted
                                        ?Color.red
                                        :Color.secondary
                                    )
                            }
                        }
                        Spacer()
                        
                        Button {
                            editedTitle = task.title
                            editedDueDate = task.dueDate ?? Date()
                            editedNoDate = task.dueDate == nil
                            taskToEdit = task
                            editedPriority = task.priority
                        } label: {
                            Image(systemName: "pencil")
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            
                            modelContext.delete(task)
                            saveChanges()
                            
                            
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.plain)
                        
                        
                    }
                }
            }
        }
        .padding(24)
        .frame(minWidth: 500, minHeight: 350)
        
        .sheet(item: $taskToEdit) { task in
            
            VStack(alignment: .leading, spacing: 16) {
                Text("edit")
                    .font(.title2)
                    .bold()
                
                
                TextField("Task Title", text: $editedTitle)
                    .textFieldStyle(.roundedBorder)
                
                Picker("Priority", selection: $editedPriority) {
                    Text("Low").tag(0)
                    Text("Medium").tag(1)
                    Text("High").tag(2)
                }
                .pickerStyle(.menu)
                
                Toggle("no date", isOn: $editedNoDate)
                
                if !editedNoDate {
                    DatePicker(
                        "Due Date",
                        selection: $editedDueDate,
                        displayedComponents: .date
                    )
                }
                HStack {
                    Button("Cancel") {
                        taskToEdit = nil
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        task.title = editedTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        task.dueDate = editedNoDate ? nil : editedDueDate
                        task.priority = editedPriority
                        saveChanges()
                        taskToEdit = nil
                        
                    }
                    .disabled(
                        editedTitle.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                    
                }
            }
            .padding(24)
            .frame(width: 380)
        }
    }
    
    private var filteredTasks: [TodoTask] {
        tasks.filter { task in
            if !showCompleted && task.isCompleted {
                return false
            }
            switch selectedFilter {
            case "Today":
                guard let dueDate = task.dueDate else {
                    return false
                }
                return Calendar.current.isDateInToday(dueDate)
                
            case "Upcoming":
                guard let dueDate = task.dueDate else {
                    return false
                }
                return Calendar.current.startOfDay(for: dueDate)
                > Calendar.current.startOfDay(for: Date())
                
            case "OVERDUE":
                guard let dueDate = task.dueDate else {
                    return false
                }
                
                return !task.isCompleted && dueDate < Calendar.current.startOfDay(for: Date())
                
            default:
                return true
            }
        }
    }
    private func addTask() {
        let title = newTaskTitle.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        
        guard !title.isEmpty else { return }
        
        
        let chosenDate = Calendar.current.date(
            from: DateComponents(
                year: selectedYear,
                month: selectedMonth,
                day: selectedDay,
                hour: 12
            )
        )
        let task = TodoTask(
            title: title,
            dueDate: noDate ? nil : chosenDate
        )
        
        task.priority = newTaskPriotity
        
        modelContext.insert(task)
        
        newTaskTitle = ""
        noDate = true
        selectedDueDate = Date()
        saveChanges()
    }
    
    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}

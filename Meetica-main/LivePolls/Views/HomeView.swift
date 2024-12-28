//
//  HomeView.swift
//  LivePolls
//
//  Created by Efe Koç on 09/07/23.
//

import SwiftUI
import MijickCalendarView


struct SignupView : View {
    @State var firstname : String = ""
    @State var email : String = ""
    @State var password : String = ""
    @State var repeatPassword : String = ""
    @State var isOk = false
    var body : some View {
        NavigationStack {
            ZStack{
                Spacer(minLength: 20)
                VStack {
                    
                    Text("Meetica").font(.title)
                    TextField("İsminizi giriniz", text: $firstname).padding(10)
                    TextField("mailinizi giriniz", text: $email).padding(10)
                    TextField("şifreiniz giriniz", text: $password).padding(10)
                    TextField("şirenizi tekrar giriniz", text: $repeatPassword).padding(10).background(Color.blue).clipShape(.capsule)
                
                    
                    Button {
                        if firstname.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty {
                            isOk = false
                        }else{
                            isOk = true
                        }
                    } label: {
                        
                           
                            Text("Signup").padding()
                        
                    }.navigationDestination(isPresented: $isOk) {
                        HomeView()
                    }

                        
                           
                    
                    
                    NavigationLink {
                        LoginView()
                    } label: {
                       
                            Text("Already have an account").padding()
                        
                       
                    }
                        

                    
                    Spacer()
                    
                }.padding(20)
                Spacer()
            }.background(Color.gray)
        }
        
        
    }
}

struct LoginView : View {
    
    @State var email : String = ""
    @State var password : String = ""

    @State var isOk = false
   
    var body : some View {
        NavigationStack {
            ZStack{
                Spacer(minLength: 20)
                VStack {
                    
                    Text("Meetica").font(.title)
                
                    TextField("mailinizi giriniz", text: $email).padding(10)
                    TextField("şifreiniz giriniz", text: $password).padding(10)
                    
                
                        
                    Button {
                        if email.isEmpty || password.isEmpty  {
                            isOk = false
                        }else{
                            isOk = true
                        }
                    } label: {
                        
                           
                            Text("Login").padding()
                        
                    }.navigationDestination(isPresented: $isOk) {
                        HomeView()
                    }
                    NavigationLink {
                        SignupView()
                    } label: {
                       
                            Text("New here? Create an account").padding()
                        
                       
                    }
                             }
                   
                        

                    
                    Spacer()
                    
                }.padding(20)
                Spacer()
            }.background(Color.gray)
        }
        

    
}


struct HomeView: View {
    
    @Bindable var vm = HomeViewModel()
    @State var selectedDate : Date = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
    
    var body: some View {
        List {
            existingPollSection
            livePollsSection
            createPollsSection
            addOptionsSection
            calendarViewSection
            
        }
        .scrollDismissesKeyboard(.interactively)
        .alert("Error", isPresented: .constant(vm.error != nil)) {
            
        } message: {
            Text(vm.error ?? "an error occured")
        }
        .sheet(item: $vm.modalPollId) { id in
            NavigationStack {
                PollView(vm: .init(pollId: id))
            }
        }
        .navigationTitle("Canlı Anketler")
        .onAppear {
            vm.listenToLivePolls()
        }
    }
    
    var existingPollSection: some View {
        Section {
            DisclosureGroup("Ankete Katıl") {
                TextField("Anket ID Girin", text: $vm.existingPollId)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Button("Katıl") {
                    Task { await vm.joinExistingPoll() }
                }
            }
        }
    }
    
    var livePollsSection: some View {
        Section {
            DisclosureGroup("Son Canlı Anketler") {
                ForEach(vm.polls) { poll in
                    VStack {
                        HStack(alignment: .top) {
                            Text(poll.name)
                            Spacer()
                            Image(systemName: "chart.bar.xaxis")
                            Text(String(poll.totalCount))
                            if let updatedAt = poll.updatedAt {
                                Image(systemName: "clock.fill")
                                Text(updatedAt, style: .time)
                            }
                        }
                        PollChartView(options: poll.options)
                            .frame(height: 120)
                    }
                    .padding(.vertical)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        vm.modalPollId = poll.id
                    }
                }
            }
            
        }
    }
    
    var createPollsSection: some View {
        Section {
            TextField("Anket adı girin", text: $vm.newPollName, axis: .vertical)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            Button("Oluştur") {
                Task { await vm.createNewPoll() }
            }.disabled(vm.isCreateNewPollButtonDisabled)
            
            if vm.isLoading {
                ProgressView()
            }
        } header: {
            Text("Anket Oluştur")
        } footer: {
            Text("Anket adını girin ve olıuşturmak için 2-4 seçenek ekleyin")
        }
    }
    
    var addOptionsSection: some View {
        Section("Seçenekler") {
            TextField("Lokasyon girin", text: $vm.newOptionName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            TextField("Etkinlik saati girin", text: $vm.newOptionName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            Button("+ Seçenek Ekle") {
                vm.addOption()
            }.disabled(vm.isAddOptionsButtonDisabled)
            
            ForEach(vm.newPollOptions) {
                Text($0)
            }.onDelete { indexSet in
                vm.newPollOptions.remove(atOffsets: indexSet)
            }
        }
    }
    
    var calendarViewSection : some View {
       

        return DatePicker("Select a date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
            
    }
}

extension String: Identifiable {
    public var id: Self { self }
}

#Preview {
    NavigationStack {
        SignupView()
    }
}

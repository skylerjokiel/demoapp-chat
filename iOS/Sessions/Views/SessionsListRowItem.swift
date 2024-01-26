///
//  SessionsListRowItem.swift
//  DittoChat
//
//  Created by Eric Turner on 1/24/24.
//
//  Copyright © 2024 DittoLive Incorporated. All rights reserved.

import SwiftUI

struct SessionsListRowItem: View {
    @Environment(SessionEditVM.self) var vm
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.allAttendees) { usr in
                    Button {
                        usr.isSelected.toggle()
                    } label: {
                        HStack {
                            Text(usr.fullName).foregroundColor(.primary)
                            
                            Spacer()
                            
                            if usr.isSelected {
                                Image(systemName: checkmarkKey)
                                    .font(.body)
                            }
                        }                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}

//#Preview {
//    SessionsListRowItem()
//}

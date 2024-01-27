//
//  ContentView.swift
//  FloatingTabs
//
//  Created by Rob Sturcke on 1/26/24.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var tabModel: TabModel = .init()
  
  var body: some View {
    TabView(selection: $tabModel.activeTab) {
      Text("Home View")
        .tag(Tab.home)
        .background(HideTabBar())
      
      Text("Favorites View")
        .tag(Tab.favorites)
      
      Text("Notifications View")
        .tag(Tab.notifications)
      
      Text("Settings View")
        .tag(Tab.settings)
      
    }
  }
}

#Preview {
  ContentView()
}

class TabModel: ObservableObject {
  @Published var activeTab: Tab = .home
}

enum Tab: String, CaseIterable {
  case home = "house.fill"
  case favorites = "suit.heart.fill"
  case notifications = "bell.fill"
  case settings = "gearshape"
}

fileprivate struct HideTabBar: NSViewRepresentable {
  func makeNSView(context: Context) -> NSView {
    return .init()
  }
  
  func updateNSView(_ nsView: NSView, context: Context) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
      if let tabView = nsView.superview?.superview?.superview as? NSTabView {
        tabView.tabViewType = .noTabsNoBorder
        tabView.tabViewBorderType = .none
        tabView.tabPosition = .none
      }
    }
  }
}

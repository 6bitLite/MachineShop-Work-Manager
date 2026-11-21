//
//  SupabaseManager.swift
//  MachineShop
//
//  Created by Mac-LAB on 10/19/26.
//

import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://lhulnmhiwzfjchtgkuta.supabase.co")!,
    supabaseKey:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxodWxubWhpd3pmamNodGdrdXRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIzODkwMTUsImV4cCI6MjEwNzk2NTAxNX0.ZZpmYEmHETKl-b-2AVsvsxgRkQL3_Oq3HecDLlzd7Ow"
)

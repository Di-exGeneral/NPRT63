enum UserRole {
  admin('MunicipalAdmin', 'Administrator'),
  maintenance('MaintenanceTeam', 'Maintenance User'),
  resident('Resident', 'Resident'),
  itStaff('ITStaff', 'IT Staff');

  final String key;
  final String label;

  const UserRole(this.key, this.label);

  bool get isAdmin => this == UserRole.admin;
  bool get canCreateFaultReport => this != UserRole.admin;

  static UserRole fromString(String? val) {
    if (val == null) return UserRole.maintenance;
    for (final r in UserRole.values) {
      if (r.name.toLowerCase() == val.toLowerCase() ||
          r.key.toLowerCase() == val.toLowerCase() ||
          r.label.toLowerCase() == val.toLowerCase()) {
        return r;
      }
    }
    if (val.toLowerCase().contains('admin')) {
      return UserRole.admin;
    }
    return UserRole.maintenance;
  }
}

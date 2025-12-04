import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Usuario? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = await authService.getCurrentUserData();
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Error al cargar usuario')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Planilla'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final authService = Provider.of<AuthService>(context, listen: false);
                await authService.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } else if (value == 'profile') {
                Navigator.of(context).pushNamed('/profile');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade500],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bienvenido/a',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser!.nombreCompleto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser!.rol.displayName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildDashboardForRole(_currentUser!.rol),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardForRole(UserRole role) {
    switch (role) {
      case UserRole.rrhh:
        return _buildRRHHDashboard();
      case UserRole.gerenteFinanciero:
        return _buildGerenteDashboard('Gerente Financiero');
      case UserRole.gerenteGeneral:
        return _buildGerenteDashboard('Gerente General');
      case UserRole.tesoreria:
        return _buildTesoreriaDashboard();
      case UserRole.contabilidad:
        return _buildContabilidadDashboard();
      case UserRole.empleado:
        return _buildEmpleadoDashboard();
    }
  }

  Widget _buildRRHHDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          icon: Icons.add_circle,
          title: 'Nueva Planilla',
          color: Colors.green,
          onTap: () => Navigator.of(context).pushNamed('/crear-planilla'),
        ),
        _buildDashboardCard(
          icon: Icons.list_alt,
          title: 'Ver Planillas',
          color: Colors.blue,
          onTap: () => Navigator.of(context).pushNamed('/listar-planillas'),
        ),
        _buildDashboardCard(
          icon: Icons.people,
          title: 'Empleados',
          color: Colors.orange,
          onTap: () => Navigator.of(context).pushNamed('/empleados'),
        ),
        _buildDashboardCard(
          icon: Icons.pending_actions,
          title: 'Pendientes Firma',
          color: Colors.purple,
          onTap: () => Navigator.of(context).pushNamed('/pendientes-rrhh'),
        ),
      ],
    );
  }

  Widget _buildGerenteDashboard(String tipo) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          icon: Icons.pending_actions,
          title: 'Planillas Pendientes',
          color: Colors.orange,
          onTap: () => Navigator.of(context).pushNamed('/pendientes-gerente'),
        ),
        _buildDashboardCard(
          icon: Icons.history,
          title: 'Historial',
          color: Colors.blue,
          onTap: () => Navigator.of(context).pushNamed('/listar-planillas'),
        ),
        _buildDashboardCard(
          icon: Icons.analytics,
          title: 'Reportes',
          color: Colors.green,
          onTap: () => Navigator.of(context).pushNamed('/reportes'),
        ),
      ],
    );
  }

  Widget _buildTesoreriaDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          icon: Icons.payment,
          title: 'Pagos Pendientes',
          color: Colors.red,
          onTap: () => Navigator.of(context).pushNamed('/pendientes-tesoreria'),
        ),
        _buildDashboardCard(
          icon: Icons.check_circle,
          title: 'Pagos Realizados',
          color: Colors.green,
          onTap: () => Navigator.of(context).pushNamed('/pagos-realizados'),
        ),
        _buildDashboardCard(
          icon: Icons.upload_file,
          title: 'Subir Comprobantes',
          color: Colors.blue,
          onTap: () => Navigator.of(context).pushNamed('/subir-comprobantes'),
        ),
      ],
    );
  }

  Widget _buildContabilidadDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          icon: Icons.pending_actions,
          title: 'Registros Pendientes',
          color: Colors.orange,
          onTap: () => Navigator.of(context).pushNamed('/pendientes-contabilidad'),
        ),
        _buildDashboardCard(
          icon: Icons.account_balance,
          title: 'Registros Contables',
          color: Colors.blue,
          onTap: () => Navigator.of(context).pushNamed('/registros-contables'),
        ),
        _buildDashboardCard(
          icon: Icons.analytics,
          title: 'Reportes',
          color: Colors.green,
          onTap: () => Navigator.of(context).pushNamed('/reportes'),
        ),
      ],
    );
  }

  Widget _buildEmpleadoDashboard() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          icon: Icons.receipt_long,
          title: 'Mis Boletas',
          color: Colors.blue,
          onTap: () => Navigator.of(context).pushNamed('/mis-boletas'),
        ),
        _buildDashboardCard(
          icon: Icons.history,
          title: 'Historial de Pagos',
          color: Colors.green,
          onTap: () => Navigator.of(context).pushNamed('/historial-pagos'),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

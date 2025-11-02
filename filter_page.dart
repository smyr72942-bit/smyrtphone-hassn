import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/job_provider.dart';

import '../providers/language_provider.dart';

class FilterPage extends StatefulWidget {

  const FilterPage({Key? key}) : super(key: key);

  @override

  State<FilterPage> createState() => _FilterPageState();

}

class _FilterPageState extends State<FilterPage> {

  String? _selectedCountry;

  String? _selectedCity = 'All';

  String? _selectedCategory = 'All';

  String? _selectedJobType = 'All';

  String? _selectedSalaryRange = 'All';

  String _searchText = '';

  final List<Map<String, String>> _categories = [

    {'ar': 'تكنولوجيا المعلومات', 'en': 'IT'},

    {'ar': 'تسويق', 'en': 'Marketing'},

    {'ar': 'مبيعات', 'en': 'Sales'},

    {'ar': 'هندسة', 'en': 'Engineering'},

    {'ar': 'تعليم', 'en': 'Education'},

    {'ar': 'طب', 'en': 'Medical'},

    {'ar': 'خدمات', 'en': 'Services'},

    {'ar': 'حكومي', 'en': 'Government'},

    {'ar': 'أمن', 'en': 'Security'},

    {'ar': 'إدارة', 'en': 'Administration'},

  ];

  final List<Map<String, String>> _jobTypes = [

    {'ar': 'دوام كامل', 'en': 'Full-time'},

    {'ar': 'دوام جزئي', 'en': 'Part-time'},

    {'ar': 'عمل حر', 'en': 'Freelance'},

    {'ar': 'تدريب', 'en': 'Internship'},

  ];

  final List<Map<String, String>> _salaryRanges = [

    {'ar': 'أقل من 500\$', 'en': 'Less than 500\$'},

    {'ar': '500–1000\$', 'en': '500–1000\$'},

    {'ar': 'أكثر من 1000\$', 'en': 'More than 1000\$'},

  ];

  String t(BuildContext context, String ar, String en) {

    final isAr = Provider.of<LanguageProvider>(context, listen: false).isArabic;

    return isAr ? ar : en;

  }

  String allLabel(BuildContext context) => t(context, 'الكل', 'All');

  void _applyFilters(BuildContext ctx) {

    final provider = Provider.of<JobProvider>(ctx, listen: false);

    provider.applyFilters(

      country: _selectedCountry == allLabel(ctx) ? null : _selectedCountry,

      city: _selectedCity == allLabel(ctx) ? null : _selectedCity,

      category: _selectedCategory == allLabel(ctx) ? null : _selectedCategory,

      jobType: _selectedJobType == allLabel(ctx) ? null : _selectedJobType,

      salaryRange: _selectedSalaryRange == allLabel(ctx) ? null : _selectedSalaryRange,

      searchText: _searchText,

    );

    final count = provider.filteredJobs.length;

    ScaffoldMessenger.of(ctx).showSnackBar(

      SnackBar(content: Text(t(ctx, 'تم العثور على $count وظيفة', '$count jobs found'))),

    );

    Navigator.of(ctx).pop();

  }

  void _clearAll(BuildContext ctx) {

    setState(() {

      _selectedCountry = null;

      _selectedCity = allLabel(ctx);

      _selectedCategory = allLabel(ctx);

      _selectedJobType = allLabel(ctx);

      _selectedSalaryRange = allLabel(ctx);

      _searchText = '';

    });

    final provider = Provider.of<JobProvider>(ctx, listen: false);

    provider.clearFilters();

    ScaffoldMessenger.of(ctx).showSnackBar(

      SnackBar(content: Text(t(ctx, 'تم مسح الفلاتر', 'Filters cleared'))),

    );

  }

  @override

  Widget build(BuildContext context) {

    final provider = Provider.of<JobProvider>(context);

    final isAr = Provider.of<LanguageProvider>(context).isArabic;

    final List<String> countryOptions = provider.countries;

    final List<String> cityOptions = _selectedCountry != null

        ? [allLabel(context), ...provider.citiesByCountry(_selectedCountry!)]

        : [allLabel(context)];

    return Directionality(

      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(

          title: Text(t(context, 'فلترة', 'Filter')),

          backgroundColor: Colors.blue,

          actions: [

            IconButton(

              icon: const Icon(Icons.close),

              onPressed: () => Navigator.of(context).pop(),

              tooltip: t(context, 'إغلاق', 'Close'),

            )

          ],

        ),

        body: SafeArea(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                TextField(

                  decoration: InputDecoration(

                    labelText: t(context, 'بحث باسم الوظيفة أو الشركة', 'Search by job or company'),

                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

                    prefixIcon: const Icon(Icons.search),

                  ),

                  onChanged: (v) => _searchText = v,

                ),

                const SizedBox(height: 16),

                _buildDropdown(

                  context,

                  label: t(context, 'الدولة', 'Country'),

                  value: _selectedCountry,

                  hint: t(context, 'اختر الدولة', 'Select country'),

                  items: [null, ...countryOptions],

                  onChanged: (v) => setState(() {

                    _selectedCountry = v;

                    _selectedCity = allLabel(context);

                  }),

                ),

                _buildDropdown(

                  context,

                  label: t(context, 'المدينة', 'City'),

                  value: _selectedCity,

                  hint: t(context, 'اختر المدينة', 'Select city'),

                  items: cityOptions,

                  onChanged: (v) => setState(() => _selectedCity = v),

                ),

                _buildDropdown(

                  context,

                  label: t(context, 'المجال / التخصص', 'Category'),

                  value: _selectedCategory,

                  hint: t(context, 'اختر المجال', 'Select category'),

                  items: [null, ..._categories.map((c) => c[isAr ? 'ar' : 'en']!)],

                  onChanged: (v) => setState(() => _selectedCategory = v),

                ),

                _buildDropdown(

                  context,

                  label: t(context, 'نوع الدوام', 'Job type'),

                  value: _selectedJobType,

                  hint: t(context, 'اختر نوع الوظيفة', 'Select job type'),

                  items: [null, ..._jobTypes.map((c) => c[isAr ? 'ar' : 'en']!)],

                  onChanged: (v) => setState(() => _selectedJobType = v),

                ),

                _buildDropdown(

                  context,

                  label: t(context, 'نطاق الراتب', 'Salary range'),

                  value: _selectedSalaryRange,

                  hint: t(context, 'اختر نطاق الراتب', 'Select salary range'),

                  items: [null, ..._salaryRanges.map((c) => c[isAr ? 'ar' : 'en']!)],

                  onChanged: (v) => setState(() => _selectedSalaryRange = v),

                ),

                const SizedBox(height: 24),

                Row(

                  children: [

                    Expanded(

                      child: ElevatedButton(

                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),

                        onPressed: () => _applyFilters(context),

                        child: Text(t(context, 'تطبيق الفلاتر', 'Apply Filters')),

                      ),

                    ),

                    const SizedBox(width: 10),

                    Expanded(

                      child: OutlinedButton(

                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),

                        onPressed: () => _clearAll(context),

                        child: Text(t(context, 'مسح الكل', 'Clear All')),

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

  Widget _buildDropdown(

    BuildContext context, {

    required String label,

    required String? value,

    required String hint,

    required List<String?> items,

    required void Function(String?) onChanged,

  }) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(

          value: value,

          decoration: InputDecoration(

            hintText: hint,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

          ),

          items: items.map((c) {

            return DropdownMenuItem<String>(

              value: c,

              child: Text(c ?? allLabel(context)),

            );

          }).toList(),

          onChanged: onChanged,

        ),

        const SizedBox(height: 16),

      ],

    );

  }

}
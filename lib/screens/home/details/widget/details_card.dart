import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loop/core/const/palette.dart';
import 'package:loop/core/const/styles.dart';

class DetailsCard extends StatelessWidget {
  final dynamic quote;

  const DetailsCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(context: context),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: Palette.themeColor),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Text("Ref No:",
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  quote['assign_id'] ?? '',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (quote['edited'] == '1')
                IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'This data already edited');
                    },
                    icon: Icon(Icons.edit)),
              if (quote['ownership_transferred'] == '1')
                IconButton(
                    onPressed: () {
                      Fluttertoast.showToast(
                          msg:
                              'Ownership transferred from ${quote['old_user_name']}');
                    },
                    icon: Icon(Icons.transfer_within_a_station_sharp)),
            ],
          ),
          InfoRow(
              icon: Icons.confirmation_number,
              label: "Quote ID:",
              value: quote['quoteid']),
          InfoRow(icon: Icons.category, label: "Plan:", value: quote['plan']),
          InfoRow(
              icon: Icons.design_services,
              label: "Service Name:",
              value: quote['service_name']),
          InfoRow(
              icon: Icons.pending,
              label: "Quote Status:",
              value: quote['status']),
          const Divider(),
          const ActionButtonRow(),
        ],
      ),
    );
  }
}

/// **Custom Widget for Displaying Key-Value Information**
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const InfoRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Palette.themeColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtonRow extends StatelessWidget {
  const ActionButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(Icons.keyboard_arrow_up_rounded),
        _buildActionButton(Icons.tag),
        _buildActionButton(Icons.manage_accounts_outlined),
        _buildActionButton(Icons.share),
      ],
    );
  }

  Widget _buildActionButton(IconData icon) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 22, color: Palette.themeColor),
    );
  }
}
